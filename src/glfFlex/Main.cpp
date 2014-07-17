#include "BaseQualityHelper.h"
#include "GlfLikelihoods.h"
#include "StringArray.h"
#include "StringAlias.h"
#include "Parameters.h"
#include "Pedigree.h"
#include "Error.h"
#include "pFile.h"

#include <math.h>
#include <time.h>
#include <limits.h>
#include <map>
#include <string>
#include <vector>
#include <fstream>

FILE * baseCalls = NULL;

class snpKey {
public:
  int pos0;
  unsigned char ref;
  unsigned char alts[3];
  int priorACs[3];
  int priorAN;

  static int char2int(char c) {
    switch(c) {
    case 'a': case 'A':
      return 1;
    case 'c': case 'C':
      return 2;
    case 'g': case 'G':
      return 3;
    case 't': case 'T':
      return 4;
    default:
      return 0;
    }
  }

  snpKey(int _pos1) : pos0(_pos1-1), priorAN(0) {
    priorACs[0] = priorACs[1] = priorACs[2] = 0;
    ref = alts[0] = alts[1] = alts[2] = 0;
  }

  snpKey(int _pos1, const char* _ref, const char* _alt, const char* _info) {
    pos0 = _pos1-1;
    ref = char2int(_ref[0]);
    alts[0] = alts[1] = alts[2] = 0;

    alts[0] = char2int(_alt[0]);
    priorAN = 0;
    priorACs[0] = priorACs[1] = priorACs[2] = 0;

    if ( _info != NULL ) {
      const char* pch = strstr(_info,"AC=");
      if ( pch != NULL ) {
	priorACs[0] = atoi(pch+3);
	const char* psemi = strchr(_info,';');
	if ( psemi == NULL )
	  psemi = pch + strlen(pch);

	pch = strchr(pch,',');
	if ( ( pch != NULL ) && ( pch < psemi ) ) {
	  priorACs[1] = atoi(pch+1);
	  pch = strchr(pch+1,',');
	  if ( ( pch != NULL ) && ( pch < psemi ) ) {
	    priorACs[2] = atoi(pch+1);
	  }
	}
      }
      pch = strstr(_info,"AN=");
      if ( pch != NULL )
	priorAN = atoi(pch+3);
    }

    if ( priorAN < priorACs[0] + priorACs[1] + priorACs[2] )
      error("priorAN = %d, priorACs = %d, %d, %d",priorAN, priorACs[0], priorACs[1], priorACs[2]);

    if ( _alt[1] == '\0' ) return;
    else if ( _alt[1] == ',' ) alts[1] = char2int(_alt[2]);
    else {
      error("Cannot recognize alternate allele %s at pos0=%d",_alt,pos0);
    }

    if ( _alt[3] == '\0' ) return;
    else if ( _alt[3] == ',' ) alts[2] = char2int(_alt[4]);
    else {
      error("Cannot recognize alternate allele %s at pos0=%d",_alt,pos0);
    }
  }
};

void ReportDate(FILE * output) {
  if (output == NULL) return;
  
  time_t systemTime;
  time(&systemTime);
  
  tm * digestedTime;
  digestedTime = gmtime(&systemTime);
  
  fprintf(output, "##filedate=%04d%02d%02d\n", digestedTime->tm_year + 1900,
	  digestedTime->tm_mon + 1,
	  digestedTime->tm_mday);
}

void DumpDetails(glfHandler * glf, int n, int position, int refBase) {
  char alleles[] = { 0, 'A', 'C', 'G', 'T' };
  
  int firstGlf = 0;
  while (glf[firstGlf].isStub)
    firstGlf++;
  
  printf("Dump for section %s, position %d [%c]\n",
	 (const char *) glf[firstGlf].label, position, alleles[refBase]);
  
  printf("Depth");
  for (int i = 0; i < n; i++)
    printf("\t%d", glf[i].GetDepth(position));
  printf("\n");
  
  printf("MapQ");
  for (int i = 0; i < n; i++)
    printf("\t%d", glf[i].GetMapQuality(position));
  printf("\n");
  
  for (int i = 1, index = 0; i <= 4; i++)
    for (int j = i; j <= 4; j++, index++)
      {
	printf("%c/%c", alleles[i], alleles[j]);
	for (int k = 0; k < n; k++)
	  printf("\t%d", glf[k].GetLogLikelihoods(position)[index]);
	printf("\n");
      }
}

int GetBestGenotype(const double likelihoods[], const double priors[])
   {
   int best = 0;

   for (int i = 1; i < 10; i++)
      if (likelihoods[i] * priors[i] > likelihoods[best] * priors[best])
         best = i;

   return best;
   }

const char * GetBestGenotypeLabel(const double likelihoods[], const double priors[])
   {
   const char * genotypeLabel[10] = {"A/A", "A/C", "A/G", "A/T", "C/C", "C/G", "C/T", "G/G", "G/T", "T/T"};

   return genotypeLabel[GetBestGenotype(likelihoods, priors)];
   }

int GetBestRatio(const double likelihoods[], const double priors[])
   {
   double sum = 0.0;
   int best = 0;

   for (int i = 1; i < 10; i++)
      if (likelihoods[i] * priors[i] > likelihoods[best] * priors[best])
         best = i;

   for (int i = 0; i < 10; i++)
      sum += likelihoods[i] * priors[i];

   if (sum <= 0.0)
      return 0;

   double error = 1.0 - likelihoods[best] * priors[best]/sum;

   if (error < 0.0000000001)
      return 100;

   return int (-log10(error) * 10 + 0.5);
   }

void ReportGenotypes(FullLikelihood & lk, glfHandler * glf, int n,
                     int position, int refAllele, int *altBases,
                     String & info, String & genotypes)
{
   info.Clear();
   genotypes.Clear();

   int ns         = 0;
   //int ac[4]      = {0, 0, 0, 0};
   double Acount  = 0.5;
   double ABcount = 1.0;

   int allele1s[10] = {1, 1, 1, 1, 2, 2, 2, 3, 3, 4};
   int allele2s[10] = {1, 2, 3, 4, 2, 3, 4, 3, 4, 4};

   //int alleleMap[5] = {99,99,99,99,99};

   //alleleMap[refAllele] = 0;
   //alleleMap[altBases[0]] = 1;
   //if ( altBases[1] > 0 ) alleleMap[altBases[1]] = 2;
   //if ( altBases[2] > 0 ) alleleMap[altBases[2]] = 3;

   int ploidies[2];
   int acs[5] = {0,0,0,0,0};
   int an = 0;

   if (lk.chromosomeType == CT_AUTOSOME) {
     ploidies[0] = 2;
     ploidies[1] = 2;
   }
   if (lk.chromosomeType == CT_CHRX) {
     ploidies[0] = 1;
     ploidies[1] = 2;
   }
   else if ( lk.chromosomeType == CT_CHRY) {
     ploidies[0] = 1;
     ploidies[1] = 0;
   }
   else if (lk.chromosomeType == CT_MITO)
     ploidies[0] = ploidies[1] = 1;

   // determine genotype index for each possible genotypes 0/0, 0/1, ...
   int gIdx[10] = {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
   int best2idx[10] = {-1,-1,-1,-1,-1,-1,-1,-1,-1};

   gIdx[0] = glfHandler::GenotypeIndex(refAllele,refAllele);
   gIdx[1] = glfHandler::GenotypeIndex(refAllele,altBases[0]);
   gIdx[2] = glfHandler::GenotypeIndex(altBases[0],altBases[0]);

   best2idx[gIdx[0]] = 0;
   best2idx[gIdx[1]] = 1;
   best2idx[gIdx[2]] = 2;

   if ( altBases[1] > 0 ) {
     gIdx[3] = glfHandler::GenotypeIndex(refAllele,altBases[1]);
     gIdx[4] = glfHandler::GenotypeIndex(altBases[0],altBases[1]);
     gIdx[5] = glfHandler::GenotypeIndex(altBases[1],altBases[1]);

     best2idx[gIdx[3]] = 3;
     best2idx[gIdx[4]] = 4;
     best2idx[gIdx[5]] = 5;
   }
   if ( altBases[2] > 0 ) {
     gIdx[6] = glfHandler::GenotypeIndex(refAllele,altBases[2]);
     gIdx[7] = glfHandler::GenotypeIndex(altBases[0],altBases[2]);
     gIdx[8] = glfHandler::GenotypeIndex(altBases[1],altBases[2]);
     gIdx[9] = glfHandler::GenotypeIndex(altBases[2],altBases[2]);

     best2idx[gIdx[6]] = 6;
     best2idx[gIdx[7]] = 7;
     best2idx[gIdx[8]] = 8;
     best2idx[gIdx[9]] = 9;
   }

   const char* labels[10] = {"0/0","0/1","1/1","0/2","1/2","2/2","0/3","1/3","2/3","3/3"};
   const char* labelsH[10] = {"0",".","1",".",".","2",".",".",".","3"};

   // allows mapping from 0-9 genotype index to this


   for (int i = 0; i < n; i++)  {
      int sex = lk.sexes[i] == SEX_MALE ? 1 : 0;

      const unsigned char * llks = glf[i].GetLogLikelihoods(position);

      int quality = lk.qualGenotypes[i];
      int best = lk.bestGenotypes[i];
      int     depth  = glf[i].GetDepth(position);

      if ( best2idx[best] < 0 ) {
	error("ref = %d, alt = %d, best = %d, best2idx[best] = %d, GPs=%.6lg,%.6lg,%.6lg,%.6lg,%.6lg,%.6lg,%.6lg,%.6lg,%.6lg,%.6lg",refAllele,altBases[0],best,best2idx[best],lk.GPs[i*10+0],lk.GPs[i*10+1],lk.GPs[i*10+2],lk.GPs[i*10+3],lk.GPs[i*10+4],lk.GPs[i*10+5],lk.GPs[i*10+6],lk.GPs[i*10+7],lk.GPs[i*10+8],lk.GPs[i*10+9]);
      }

      if ( ploidies[sex] == 2 ) {
	genotypes.catprintf("\t%s:%d:%d",labels[best2idx[best]],depth,quality);
	++acs[allele1s[best]];
	++acs[allele2s[best]];
	if ( depth > 0 ) {
	  an += 2;
	  ++ns;
	}
      }
      else if ( ploidies[sex] == 1 ) {
	genotypes.catprintf("\t%s:%d:%d",labelsH[best2idx[best]],depth,quality);
	++acs[allele1s[best]];
	if ( depth > 0 ) {
	  ++an;
	  ++ns;
	}
      }
      else {
	genotypes.catprintf("\t.:%d:0",depth);
      }


      double pHet = 0;
      if ( altBases[1] == 0 ) { // biallelic
	genotypes.catprintf(":%d,%d,%d",llks[gIdx[0]], llks[gIdx[1]], llks[gIdx[2]]);
	pHet = lk.GPs[10*i+gIdx[1]]/lk.sumPs[i];
      }
      else if ( altBases[2] == 0 ) { // triallelic
	genotypes.catprintf(":%d,%d,%d,%d,%d,%d",llks[gIdx[0]], llks[gIdx[1]], llks[gIdx[2]], llks[gIdx[3]], llks[gIdx[4]], llks[gIdx[5]]);
	pHet = lk.GPs[10*i+gIdx[1]]/(lk.GPs[10*i+gIdx[0]]+lk.GPs[10*i+gIdx[1]]+lk.GPs[10*i+gIdx[2]]+1e-30);
      }
      else { // four alleles
	genotypes.catprintf(":%d,%d,%d,%d,%d,%d",llks[gIdx[0]], llks[gIdx[1]], llks[gIdx[2]], llks[gIdx[3]], llks[gIdx[4]], llks[gIdx[5]], llks[gIdx[6]], llks[gIdx[7]], llks[gIdx[8]], llks[gIdx[9]]);
	pHet = lk.GPs[10*i+gIdx[1]]/(lk.GPs[10*i+gIdx[0]]+lk.GPs[10*i+gIdx[1]]+lk.GPs[10*i+gIdx[2]]+1e-30);
      }

      if ( ( depth > 0 ) && ( pHet > 1e-5 ) ) { 
	int scale = llks[gIdx[2]] + llks[gIdx[0]] - 2 * llks[gIdx[1]] + 6 * depth;
	int minimum = abs(llks[gIdx[2]] - llks[gIdx[0]]);
	
	if (scale < 4) scale = 4;
	if (scale < minimum) scale = minimum;
	
	double delta = (llks[gIdx[2]] - llks[gIdx[0]])
	  / (scale + 1e-30);
	double nref = 0.5 * depth * (1.0 + delta);
	
	Acount += pHet * nref;
	ABcount += pHet * depth;
      }
   }

   info.catprintf("NS=%d", ns);
   info.catprintf(";AN=%d", an);
   info.catprintf(";AC=%d", acs[altBases[0]]);
   if ( altBases[1] != 0 ) {
     info.catprintf(",%d", acs[altBases[1]]);
     if ( altBases[2] != 0 ) {
       info.catprintf(",%d", acs[altBases[2]]);
     }
   }
   info.catprintf(";AF=%.6lf", lk.freqs[altBases[0]]);
   if ( altBases[1] != 0 ) {
     info.catprintf(",%.6lf", lk.freqs[altBases[1]]);
     if ( altBases[2] != 0 ) {
       info.catprintf(",%.6lf", lk.freqs[altBases[2]]);
     }
   }

   double AB = Acount / (ABcount + 1e-30);
   double AZ = (Acount - 0.5*ABcount)/sqrt(ABcount*0.25 + 1e-30);

   info.catprintf(";AB=%.4lf;AZ=%.4lf", AB, AZ);

   double inbreedingCoeff = lk.inbreedingCoeff();
   double signedLRT = (inbreedingCoeff > 0 ? 1 : -1) * lk.hwdLRT();

   info.catprintf(";FIC=%.4lf;SLRT=%.4lf", inbreedingCoeff, signedLRT );

   //info.catprintf(";HWDGF=%.6lf,%.6lf,%.6lf", lk.dfreqs[gIdx[0]], lk.dfreqs[gIdx[1]], lk.dfreqs[gIdx[2]] );
}

void ReportSNP(FullLikelihood & lk,
	       int n, int position,
	       int refBase, int* altBases,
	       const char * filter,
	       int totalCoverage, int rmsMapQuality, double log10post) {
   if (baseCalls == NULL) return;

   char alleles[] = { 0, 'A', 'C', 'G', 'T' };

   glfHandler * glf = lk.glf;

   // Find the location of the first non-stub glf
   int firstGlf = 0;
   while (glf[firstGlf].isStub)
      firstGlf++;

   // #Chrom   Pos   Id
   fprintf(baseCalls, "%s\t%d\t.\t", (const char *) glf[firstGlf].label, position + 1);

   // Reference allele
   fprintf(baseCalls, "%c\t", alleles[refBase]);

   if ( altBases[0] != 0 ) 
     fprintf(baseCalls, "%c", alleles[altBases[0]]);
   else
     fprintf(baseCalls, ".");

   if ( altBases[1] != 0 )
     fprintf(baseCalls, ",%c", alleles[altBases[1]]);
   if ( altBases[2] != 0 )
     fprintf(baseCalls, ",%c", alleles[altBases[2]]);

   fprintf(baseCalls, "\t");

   double quality = (-10.0 * log10post);//posterior > 0.9999999999 ? 100 : (int)(-10 * log10(1.0 - posterior));
   //double log10post = 0-log10( prior * exp(lFull-lRef) + 1.0 );
   //int quality = (int)(10.0 * log10( prior * exp(0-lk.min-lRef) + 1.0 ));


   // Quality for this call
   //fprintf(baseCalls, "%lf,%lf\t", lRef, 0-lk.min);
   fprintf(baseCalls, "%.3lf\t", quality);

   // Filter for this call
   fprintf(baseCalls, "%s\t", filter == NULL || filter[0] == 0 ? "PASS" : filter);

   String info, genotypes;

   ReportGenotypes(lk, glf, n, position, refBase, altBases, info, genotypes);

   // Information for this call
   fprintf(baseCalls, "DP=%d;MQ=%d;", totalCoverage, rmsMapQuality);
   fprintf(baseCalls, "%s\t", (const char *) info);

   // Format for this call
   fprintf(baseCalls, "GT:DP:GQ:PL");

   fprintf(baseCalls, "%s\n", (const char *) genotypes);
}

double FilteringLikelihood
         (FilterLikelihood & lk, int n, int position, int refAllele)
{
  lk.SetReferenceAllele(refAllele);
  lk.OptimizeFrequency();
  
  return -lk.fmin;
}

double PolymorphismLikelihood
(GenotypeLikelihood & lk, int n, int position, int refAllele, int mutAllele)
{
  lk.SetAlleles(refAllele, mutAllele);
  lk.OptimizeFrequency();
  
  return -lk.fmin;
}

double SinkLikelihood
(glfHandler * glf, int n, int position)
{
  double lk = 0.0;
  double scale = -log(10.0) / 10;
  
  for  (int r = 1; r <= 4; r++)
    for (int m = r + 1; m <= 4; m++)
      {
	int geno = glfHandler::GenotypeIndex(r, m);
	
	double partial = log(1.0 / 6.0);
	for (int i = 0; i < n; i++)
	  partial += glf[i].GetLogLikelihoods(position)[geno] * scale;
	
	if (lk == 0.0)
	  {
            lk = partial;
            continue;
	  }
	
	double max = partial > lk ? partial : lk;
	double min = partial > lk ? lk : partial;
	
	if (max - min > 50)
	  lk = max;
	else
	  lk = log(exp(partial - min) + exp(lk - min)) + min;
      }
  
  return lk;
}


void getRegionInfo(const String& region, String& regionChr, 
                   int& regionStart, int& regionEnd)
{
    regionChr.Clear();
    regionStart = 0;
    regionEnd = -1;
    if(!region.IsEmpty())
    {
        // Only process a specific region.
        int chrStrEnd = region.FastFindChar(':',1);
        if(chrStrEnd < 1)
        {
            regionChr = region;
            printf("Processing only Chromosome %s\n", regionChr.c_str());
        }
        else
        {
            regionChr = region.Left(chrStrEnd);
            // get the start region position.
            int startStrEnd = region.FastFindChar('-',chrStrEnd);

            String startStr;
            if(startStrEnd < chrStrEnd)
            {
                startStr = region.SubStr(chrStrEnd+1);
            }
            else
            {
                startStr = region.Mid(chrStrEnd+1, startStrEnd-1);
            }
            // Convert the start string to an integer
            if(!startStr.AsInteger(regionStart))
            {
                String errorStr = "Error: Invalid --region string, '";
                errorStr += region;
                errorStr += "', the start position, '";
                errorStr += startStr;
                errorStr += "', is not an integer.";
                error(errorStr.c_str());
            }
            
            if(startStrEnd < chrStrEnd)
            {
                // No end position.
                printf("Processing only Chromosome %s, starting from %d\n",
                       regionChr.c_str(), regionStart);
            }
            else
            {
                String endStr = region.SubStr(startStrEnd+1);
                // Convert to integer.
                if(!endStr.AsInteger(regionEnd))
                {
                    String errorStr = "Error: Invalid --region string, '";
                    errorStr += region;
                    errorStr += "', the end position, '";
                    errorStr += endStr;
                    errorStr += "', is not an integer.";
                    error(errorStr.c_str());
                }

                printf("Processing only Chromosome %s, positions %d - %d\n", 
                       regionChr.c_str(), regionStart, regionEnd);
            }
        }
   }
}


int main(int argc, char ** argv) {
  printf("glfMultiples -- SNP calls based on .glf or .glz files\n");
  printf("(c) 2008-2014 Goncalo Abecasis, Sebastian Zoellner, Yun Li, Hyun Min Kang, and Mary Kate Trost\n\n");
  
  String pedfile;
  String positionfile;
  String callfile;
  String glfAliases;
  String region;
  String sfsfile;  // custom site frequency spectrum
  bool afprior = false;    // use AF prior from site vcf
  bool skipDetect = false; // skip variant detection
  bool printMono = true;  // print monomorphic variants
  bool glfsingle = false;  // use glfsingle model
  ParameterList pl;
  
  bool   uniformTsTv = false;
  double theta = 0.001;
  
  double posterior = 0.50;
  int    minMapQuality = 0;
  int    minTotalDepth = 1;
  int    maxTotalDepth = INT_MAX;
  bool   verbose = false;
  bool   mapQualityStrict = false;
  bool   hardFilter = false;
  bool   smartFilter = false;
  bool   softFilter = true;
  //bool   vcfPosFilter = true;
  String xLabel("X"), yLabel("Y"), mitoLabel("MT");
  int    xStart = 2699520, xStop = 154931044;
  
  BEGIN_LONG_PARAMETERS(longParameters)
    LONG_PARAMETER_GROUP("Pedigree File")
    LONG_STRINGPARAMETER("ped", &pedfile)

    LONG_PARAMETER_GROUP("Model")
    LONG_PARAMETER("uniformTsTv", &uniformTsTv)
    LONG_DOUBLEPARAMETER("heterozygosity", &theta)
    LONG_STRINGPARAMETER("sfs",&sfsfile)
    LONG_PARAMETER("glfsingle", &glfsingle)

    LONG_PARAMETER_GROUP("Map Quality Filter")
    LONG_INTPARAMETER("minMapQuality", &minMapQuality)
    LONG_PARAMETER("strict", &mapQualityStrict)

    LONG_PARAMETER_GROUP("Total Depth Filter")
    LONG_INTPARAMETER("minDepth", &minTotalDepth)
    LONG_INTPARAMETER("maxDepth", &maxTotalDepth)

    LONG_PARAMETER_GROUP("Position Filter")
    LONG_STRINGPARAMETER("positionFile", &positionfile)
    LONG_PARAMETER("skipDetect",&skipDetect)
    //    LONG_PARAMETER("printMono",&printMono)
    LONG_PARAMETER("afPrior",&afprior)

    LONG_PARAMETER_GROUP("Chromosome Labels")
    LONG_STRINGPARAMETER("xChr", &xLabel)
    LONG_STRINGPARAMETER("yChr", &yLabel)
    LONG_STRINGPARAMETER("mito", &mitoLabel)
    LONG_INTPARAMETER("xStart", &xStart)
    LONG_INTPARAMETER("xStop", &xStop)

    LONG_PARAMETER_GROUP("Filtering Options")
    EXCLUSIVE_PARAMETER("hardFilter", &hardFilter)
    EXCLUSIVE_PARAMETER("smartFilter", &smartFilter)
    EXCLUSIVE_PARAMETER("softFilter", &softFilter)

    LONG_PARAMETER_GROUP("Region(optional)")
    LONG_STRINGPARAMETER("region", &region)
    LONG_PARAMETER_GROUP("Output")
    LONG_PARAMETER("verbose", &verbose)

    LONG_PARAMETER_GROUP("Sample Names")
    LONG_STRINGPARAMETER("glfAliases", &glfAliases)
   END_LONG_PARAMETERS();

   pl.Add(new StringParameter('b', "Base Call File", callfile));
   pl.Add(new DoubleParameter('p', "Posterior Threshold", posterior));
   pl.Add(new LongParameters("Additional Options", longParameters));
   int argstart = pl.ReadWithTrailer(argc, argv) + 1;
   pl.Status();

   if (posterior < 0)
      error("Posterior threshold for genotype calls (-p option) must be > 0.");

   time_t t;
   time(&t);

   printf("Analysis started on %s\n", ctime(&t));
   fflush(stdout);

   int n = argc - argstart;
   argv += argstart;

   Pedigree ped;
   if (!pedfile.IsEmpty())
      {
      ped.pd.AddStringColumn("glfFile");
      ped.Load(pedfile);

      n = ped.count;
      }
   else
      if (n == 0)
         error("No pedigree file present and no glf files listed at the end of command line\n");

   // Determine if only a subset of the regions are being processed.
   String regionChr;
   int regionStart = 0;
   int regionEnd = -1;

   getRegionInfo(region, regionChr, regionStart, regionEnd);

   // Prior for finding difference from the reference at a particular site
   double prior = 0.0;
   double * sfs = new double[ n + n + 1 ];
   if ( sfsfile.IsEmpty() ) {
     double sum = 0;
     for (int i = 1; i <= 2 * n; ++i) {
       sfs[i] = 1.0 / i;
       sum += sfs[i];
     }
     for (int i = 1; i <= 2 * n; ++i) {
       sfs[i] /= sum;
     }
   }
   else {
     StringArray buf, tok;
     buf.Read(sfsfile);
     double sum = 0;
     for (int i = 1; i <= 2 * n; ++i) {
       sfs[i] = 0;
     }
     for(int i=0; i < buf.Length(); ++i) {
       tok.ReplaceTokens(buf[i], " \t");
       if ( tok.Length() != 2 ) 
	 error("Site frequency spectrum file %s must have two columns",(const char*)sfsfile);
       int ac = tok[0].AsInteger();
       if ( ( ac < 0 ) || ( ac > 2 * n ) ) {
	 error("Allele count %d is beyond the interval [%d, %d]", ac, 0, 2 * n);
       }
       if ( sfs[ac] > 0 ) {
	 error("Allele count %d appears twice in %s", ac, (const char*)sfsfile);
       }
       sfs[ ac ] = tok[1].AsDouble();
       sum += sfs[ac];
     }
     for (int i = 1; i <= 2 * n; ++i) {
       sfs[i] /= sum;
     }
   }

   // now, the prior needs to be normalized
   prior = 0.0;
   for(int i = 1; i <= 2 * n; ++i) {
     prior += (double)(i*(2*n-i))/(double)(n*(2*n-1))*sfs[i];  // this quantifies heterozygosity per site
   }
   prior = theta / prior;

   printf("Pairwise heterozogosity : %.6lf\nProportion of polymorphic site : %.6lf\n", theta, prior );

   glfHandler * glf = new glfHandler[n];

   int firstGlf = n;
   if (ped.count) {
      bool warn = false;

      bool anyOpened = false;

      for (int i = n - 1; i >= 0; i--)
         if (!glf[i].Open(ped[i].strings[0])) {
            printf("Failed to open genotype likelihood file [%s] for individual %s:%s\n",
                   (const char *) ped[i].strings[0],
                   (const char *) ped[i].famid,
                   (const char *) ped[i].pid);

            glf[i].OpenStub();
	 }
         else {
             anyOpened = true;
             if(ifeof(glf[i].handle) != 0) {
                 // Empty GLF (just header).
                 // Close it and open a stub.
                 warning("GLF file '%s' appears empty ...\n",
                         ped.count ? (const char *) ped[i].strings[0] : argv[i]);
                 glf[i].Close();
                 glf[i].OpenStub();
             }
             else {
                 firstGlf = i;
             }
         }

      if (warn)
         printf("\n");

      if ((firstGlf == n) && (!anyOpened))
         error("No genotype likelihood files could be opened");
      }
   else
      for (int i = n - 1; i >= 0; i--)
         if (!glf[i].Open(argv[i]))
            error("Failed to open genotype likelihood file [%s]\n", argv[i]);
         else
            firstGlf = i;

   StringAlias aliases;
   aliases.ReadFromFile(glfAliases);

   printf("Calling genotypes for files ...\n");
   for (int i = 0; i < n; i++)
      printf("%s\n", ped.count ? (const char *) ped[i].strings[0] : argv[i]);
   printf("\n");

   baseCalls = fopen(callfile, "wt");

   if (baseCalls != NULL) {
      fprintf(baseCalls, "##fileformat=VCFv4.1\n");
      ReportDate(baseCalls);
      fprintf(baseCalls, "##source=glfMultiples\n");
      fprintf(baseCalls, "##minDepth=%d\n", minTotalDepth);
      if (maxTotalDepth != INT_MAX) fprintf(baseCalls, "##maxDepth=%d\n", maxTotalDepth);
      fprintf(baseCalls, "##minMapQuality=%d\n", minMapQuality);
      fprintf(baseCalls, "##minPosterior=%.4f\n", posterior);
      fprintf(baseCalls, "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth at Site\">\n");
      fprintf(baseCalls, "##INFO=<ID=MQ,Number=1,Type=Integer,Description=\"Root Mean Squared Mapping Quality\">\n");
      fprintf(baseCalls, "##INFO=<ID=NS,Number=1,Type=Integer,Description=\"Number of Samples With Coverage\">\n");
      fprintf(baseCalls, "##INFO=<ID=AN,Number=1,Type=Integer,Description=\"Number of Alleles in Samples with Coverage\">\n");
      fprintf(baseCalls, "##INFO=<ID=AC,Number=.,Type=Integer,Description=\"Alternate Allele Counts in Samples with Coverage\">\n");
      fprintf(baseCalls, "##INFO=<ID=AF,Number=.,Type=Float,Description=\"Alternate Allele Frequencies\">\n");
      fprintf(baseCalls, "##INFO=<ID=AB,Number=1,Type=Float,Description=\"Allele Balance in Heterozygotes\">\n");
      fprintf(baseCalls, "##FILTER=<ID=mq%d,Description=\"Mapping Quality Below %d\">\n", minMapQuality, minMapQuality);
      fprintf(baseCalls, "##FILTER=<ID=dp%d,Description=\"Total Read Depth Below %d\">\n", minTotalDepth, minTotalDepth);
      if (maxTotalDepth != INT_MAX)
         fprintf(baseCalls, "##FILTER=<ID=DP%d,Description=\"Total Read Depth Above %d\">\n", maxTotalDepth, maxTotalDepth);
      fprintf(baseCalls, "##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Most Likely Genotype\">\n");
      fprintf(baseCalls, "##FORMAT=<ID=GQ,Number=1,Type=Integer,Description=\"Genotype Call Quality\">\n");
      fprintf(baseCalls, "##FORMAT=<ID=DP,Number=1,Type=Integer,Description=\"Read Depth\">\n");
      fprintf(baseCalls, "##FORMAT=<ID=PL,Number=.,Type=Integer,Description=\"Genotype Likelihoods for Genotypes in Phred Scale, for 0/0, 0/1, 1/1, 0/2, 1/2, 2/2, ...\">\n");
      fprintf(baseCalls, "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT");
      for (int i = 0; i < n; i++) {
         fprintf(baseCalls, "\t%s", ped.count ?
		 ( (ped[i].famid.Compare(ped[i].pid) == 0) ? 
		   (const char*)(ped[i].pid) :
		   (const char *) (ped[i].famid + ":" + ped[i].pid) ) 
		   : (const char *) aliases.GetAlias(argv[i]));
      }

      fprintf(baseCalls, "\n");
   }

   // Prepare an array of filters. Positions are stored as strings, in the
   // format chr:position or as VCF input files
   // The input position map must be stored
   // * if position file is specified, no allele information will be stored
   // * if VCF is specified, allele information will be known to be assumed
   // * with --afprior, AF information will be added to it

   String buffer;
   //StringArray tokens, tokens2, vcfTokens;
   std::map<std::string, std::vector<snpKey> > pos;

   if ( !positionfile.IsEmpty() ) {
     int nkeys = 0;
     pFile posFile;
     // check whether indexfile exists
     std::ifstream f((const char*)(positionfile + ".tbi"));
     if (f.good()) {
       f.close();
       posFile.load(positionfile, region.IsEmpty() ? NULL : (const char*)region);
     } else {
        f.close();
	posFile.load(positionfile, NULL);
     }   

     const char* line = NULL;
     std::vector<std::string> tokens, tokens2;
     int pos1;
     while( ( line = posFile.getLine() ) != NULL ) {
       if ( line[0] == '#' ) continue;

       pFile::tokenizeLine(line, " \t\r\n", tokens);
       if (tokens.size() < 2) {
	 pFile::tokenizeLine(tokens[0].c_str(),":",tokens2);
	 if ( tokens2.size() < 2 )
	   warning("Line %s was not recognized and skipped in %s",tokens[0].c_str(), (const char*)positionfile);
	 else {
	   pos1 = atoi(tokens2[1].c_str());
	   if ( !regionChr.IsEmpty() ) {
	     if ( tokens2[0].compare((const char*)regionChr) != 0 )
	       continue;
	     if ( ( pos1 < regionStart ) || ( pos1 > regionEnd ) ) 
	       continue;
	   }
	   pos[tokens2[0]].push_back( snpKey(pos1) );
	 }
       }
       else if ( tokens.size() < 5 ) { // VCF-like [CHROM] [POS] [ID] [REF] [ALT]
	 pos1 = atoi(tokens[1].c_str());
	 if ( !regionChr.IsEmpty() ) {
	   if ( tokens[0].compare((const char*)regionChr) != 0 )
	     continue;
	   if ( ( pos1 < regionStart ) || ( pos1 > regionEnd ) ) 
	     continue;
	 }
	 pos[tokens[0]].push_back( snpKey(pos1) );
       }
       else  {
	 pos1 = atoi(tokens[1].c_str());

	 // check if the variant is SNP
	 bool isSNP = true;
	 if ( tokens[3].size() != 1 ) {
	   isSNP = false;
	 }
	 else {
	   for(int i=0; i < (int)tokens[4].size(); ++i) {
	     switch(tokens[4][i]) {
	     case 'a': case 'A': case 'c': case 'C': case 'g': case 'G': case 't': case 'T':
	       if ( i % 2 != 0 ) {
		 isSNP = false;
	       }
	       break;
	     case ',':
	       if ( i % 2 != 1 ) {
		 isSNP = false;
	       }
	       break;
	     default:
	       isSNP = false;
	     }
	   }
	   if ( tokens[4].size() > 5 ) {
	     isSNP = false;
	   }
	 }

	 if ( !isSNP ) {
	   fprintf(stderr,"%s:%s_%s/%s in %s is not a SNP.. Skipping..\n",tokens[0].c_str(),tokens[1].c_str(),tokens[3].c_str(),tokens[4].c_str(),positionfile.c_str());
	   continue;
	 }

	 //fprintf(stderr,"%d\n",pos1);

	 pos[tokens[0]].push_back( snpKey(pos1, tokens[3].c_str(), tokens[4].c_str(), (tokens.size() >=8 && afprior ) ? tokens[7].c_str() : NULL ) );
	 ++nkeys;
       }
     }
     printf("Finished loading %d SNPs for unconditional genotyping\n",nkeys);
   }
   else if ( skipDetect ) {
     error("--skipDetect option requires to specify --positionFile option");
   }

   // Prepare GenotypeLikelihood calculator, which will use sex information,
   // if available
   GenotypeLikelihood lkGeno(n, glf);
   FilterLikelihood lkFilter(n, glf);
   FullLikelihood lkFull(n, glf);

   lkGeno.glf = lkFilter.glf = lkFull.glf = glf;
   lkGeno.n = lkFilter.n = lkFull.n = n;

   /*
   IFILE vcfFile = sitevcf.IsEmpty() ? NULL : ifopen(sitevcf,"rb");
   int vcfPos;
   if ( vcfFile != NULL ) {
     while( buffer.ReadLine(vcfFile) > 0 ) {
     }
     vcfTokens.ReplaceColumns(buffer, '\t');
     if ( vcfTokens.Length() < 8 )
       error("Input VCF file needs to have at least 8 columns");
     vcfPos = vcfTokens[1].AsInteger();
   }
   */
   
   if (ped.count)
      for (int i = 0; i < ped.count; i++)
         lkGeno.sexes[i] = lkFilter.sexes[i] = ped[i].sex == SEX_MALE ? SEX_MALE : SEX_FEMALE;

   int chromosomeType = 0;

   // Main loop, which iterates through chromosomes and then positions
   while((firstGlf != n) && (glf[firstGlf].NextSection())) {
     // synchronize the base position between glf files
     for (int i = firstGlf + 1; i < n; i++) {
       if (glf[i].isStub) continue;
       
       if ( !glf[i].NextSection() ) {
	 warning("GLF file '%s' appears empty ...\n",
		 //"    File '%s' section %s with %d entries ...\n",
		 ped.count ? (const char *) ped[i].strings[0] : argv[i],
		 ped.count ? (const char *) ped[i].strings[0] : argv[i],
		 (const char *) glf[i].label, glf[i].maxPosition);
	 glf[i].isStub = true;
	 glf[i].position = glf[i].maxPosition = glf[firstGlf].maxPosition;
	 continue;
       }

       if (glf[firstGlf].maxPosition != glf[i].maxPosition || glf[firstGlf].label != glf[i].label) {
	   error("Genotype files '%s' and '%s' are not compatible ...\n"
		 "    File '%s' has section %s with %d entries ...\n"
		 "    File '%s' section %s with %d entries ...\n",
		 ped.count ? (const char *) ped[firstGlf].strings[0] : argv[firstGlf],
		 ped.count ? (const char *) ped[i].strings[0] : argv[i],
		 ped.count ? (const char *) ped[firstGlf].strings[0] : argv[firstGlf],
		 (const char *) glf[firstGlf].label, glf[firstGlf].maxPosition,
		 ped.count ? (const char *) ped[i].strings[0] : argv[i],
		 (const char *) glf[i].label, glf[i].maxPosition);
       }
     }

     // If the region is specified, continue if this is not the correct chromosome.
     if(!region.IsEmpty()) {
       if(glf[firstGlf].label != regionChr)
	 continue;
     }

     std::vector<snpKey>& keys = pos[(const char*)glf[firstGlf].label];

     chromosomeType = CT_AUTOSOME;

     if (ped.count) {
       if (glf[firstGlf].label == xLabel) chromosomeType = CT_CHRX;
       if (glf[firstGlf].label == yLabel) chromosomeType = CT_CHRY;
       if (glf[firstGlf].label == mitoLabel) chromosomeType = CT_MITO;
     }
      
     int endPos = glf[firstGlf].maxPosition;
     if((regionEnd != -1) && (regionEnd < endPos)) {
       endPos = regionEnd;
     }
     int numEntries = endPos - regionStart;
     printf("Processing section %s with %d entries\n",
	    (const char *) glf[firstGlf].label, numEntries);

     int refBase = 0;
     int mapQualityFilter = 0;
     int depthFilter = 0;
     int homozygousReference = 0;
     //int transitions = 0;
     //int transversions = 0;
     //int otherPolymorphisms = 0;
     int sinkFilter = 0;
     int smartFilterHits = 0;
     int baseCounts[5] = {0, 0, 0, 0, 0};

     String filter;
     int keyCursor = 0; // current index
     int newPos0 = -1;
     int altBases[3];
     //int quality;

     if ( regionStart > 0 ) {
       while( keyCursor < (int)keys.size() && keys[keyCursor].pos0 < regionStart-1 ) 
	 ++keyCursor;
     }
     
     while (true) {
       if (newPos0 > 0) {
	 // Check whether we have reached the end of the current chromosome
	 bool done = true;
	 for (int i = 0; i < n; i++)
	   if (glf[i].data.recordType != 0)
	     done = false;
	 if (done) break;
       }

       // Advance to the next position where needed
       if ( keyCursor < (int)keys.size() && keys[keyCursor].pos0 == newPos0 ) {
	 // keep newPos0;
       }
       else {
	 newPos0 = skipDetect ? ( keyCursor < (int)keys.size() ? keys[keyCursor].pos0 : -1 ) : newPos0 + 1;
       }

       /*
       if ( newPos0 % 10000 == 0 )
	 fprintf(stderr,"newPos0=%d\n",newPos0);
       */

       if ( newPos0 < 0 ) break;

       if ( newPos0 < regionStart-1 ) {
	 newPos0 = regionStart-1;
       }

       while( keyCursor < (int)keys.size() && keys[keyCursor].pos0 < newPos0 ) 
	 ++keyCursor;

       bool inKeys = ( keyCursor < (int) keys.size() && keys[keyCursor].pos0 == newPos0 );

       int minPos0 = INT_MAX;

       for (int i = 0; i < n; i++) {
	 while( newPos0 > glf[i].position ) {
	   glf[i].NextBaseEntry();
	 }

	 if ( minPos0 > glf[i].position ) 
	   minPos0 = glf[i].position;
       }

       if ( minPos0 > newPos0 ) { // newPosition does not have any supporting reads
	 if ( inKeys && printMono ) {
	   // do not change newPos0s
	 }
	 else {
	   //fprintf(stderr,"** %d %d\n",newPos0,minPos0);
	   if ( keyCursor < (int) keys.size() && keys[keyCursor].pos0 < minPos0 ) {
	     newPos0 = keys[keyCursor].pos0;
	     inKeys = true;
	   }
	   else 
	     newPos0 = minPos0;
	 }
       }
       else if ( minPos0 < newPos0 ) {  // something is wrong..
	 error("minPos0 %d < newPos0 %d",minPos0,newPos0);
       }

       if ( inKeys ) {
	 refBase = keys[keyCursor].ref;
	 altBases[0] = keys[keyCursor].alts[0];
	 altBases[1] = keys[keyCursor].alts[1];
	 altBases[2] = keys[keyCursor].alts[2];
       }
       else {
	 if ( minPos0 == newPos0 ) {
	   for(int i=0; i < n; ++i) {
	     if ( newPos0 == glf[i].position ) {
	       refBase = glf[i].data.refBase;
	       altBases[0] = altBases[1] = altBases[2] = 0;
	       break;
	     }
	   }
	 }
	 else {
	   error("minPos0 %d != newPos0 %d",minPos0,newPos0);
	 }
       }

       // Avoid alignments that extend past the end of the chromosome
       if (newPos0 >= endPos)
            break;

       baseCounts[refBase]++;

       // These lines can be uncommented for debugging purposes
       // for (int i = 0; i < n; i++)
       //   printf("GLF %d : position %d, refBase %d\n", i, position, refBase);
       // printf("Position: %d, refBase: %d\n", position, refBase);

       if (refBase == 0) continue;

       if ( (!inKeys) && skipDetect && altBases[0] == 0 ) continue;

       filter.Clear();

       int     totalDepth = 0, nSamplesCovered = 0;
       double  rmsMapQuality = 0.0;
       bool    passMapQualityFilter = false;
       
       for (int i = 0; i < n; i++) {
	 int depth = glf[i].GetDepth(newPos0);
	 
	 if (depth > 0) {
	   totalDepth += depth;
	   nSamplesCovered++;
	   
	   int mapQuality = glf[i].GetMapQuality(newPos0);
	   rmsMapQuality += depth * mapQuality * mapQuality;
	   
	   if (mapQuality >= minMapQuality)
	     passMapQualityFilter = true;
	 }
       }
       rmsMapQuality = sqrt(rmsMapQuality / (totalDepth + 1e-15));
       
       if (!passMapQualityFilter) {
	 if (filter.Length() == 0) mapQualityFilter++;
	 if (hardFilter) continue;
	 filter.catprintf("%sMQ.lt.%d", filter.Length() ? ";" : "", minMapQuality);
       }
       
       if (totalDepth < minTotalDepth) {
	 if (filter.Length() == 0) depthFilter++;
	 if (hardFilter) continue;
	 filter.catprintf("%sDP.lt.%d", filter.Length() ? ";" : "", minTotalDepth);
       }
       
       if (totalDepth > maxTotalDepth) {
	 if (filter.Length() == 0) depthFilter++;
	 if (hardFilter) continue;
	 filter.catprintf("%sDP.gt.%d", filter.Length() ? ";" : "", maxTotalDepth);
       }
       


       // Create convenient aliases for each base
       unsigned char transition = (((refBase - 1) ^ 2) + 1);
       unsigned char transvers1 = (((refBase - 1) ^ 3) + 1);
       unsigned char transvers2 = (((refBase - 1) ^ 1) + 1);
       
       int homRef = glf[0].GenotypeIndex(refBase, refBase);

       // Transition / Transversion rate prior
       double pTs = uniformTsTv ? 1./3. : 2./3.;
       double pTv = uniformTsTv ? 1./3. : 1./6.;
       double lRef = log(1.0 - prior);
       for (int i = 0; i < n; i++)
	 lRef += log(glf[i].GetLikelihoods(newPos0)[homRef]);

       // Figure out the correct type of analysis
       lkGeno.position = lkFilter.position = lkFull.position = newPos0;
       lkGeno.chromosomeType = lkFilter.chromosomeType = lkFull.chromosomeType =
	 chromosomeType != CT_CHRX ?
	 chromosomeType :
	 newPos0 >= xStart && newPos0 <= xStop ? CT_CHRX : CT_AUTOSOME;
       
       if ( altBases[0] == 0 ) { // need to determine alternate allele
	 if ( glfsingle ) {  // use glfSingle model to detect variants
	   // consider alleles with supporting evidence
	   //double lRef, lHet, lHom;
	   double sum, threshold;
	   int idxs[10];
	   const double* lks;
	   double priors[10];
	   double posts[10];
	   double maxpost;
	   int imaxpost, al1, al2;
	   int allele1s[10] = {1, 1, 1, 1, 2, 2, 2, 3, 3, 4};
	   int allele2s[10] = {1, 2, 3, 4, 2, 3, 4, 3, 4, 4};

	   idxs[0] = homRef;
	   idxs[1] = glf[0].GenotypeIndex(refBase, transition);
	   idxs[2] = glf[0].GenotypeIndex(refBase, transvers1);
	   idxs[3] = glf[0].GenotypeIndex(refBase, transvers2);
	   idxs[4] = glf[0].GenotypeIndex(transition, transition);
	   idxs[5] = glf[0].GenotypeIndex(transvers1, transvers1);
	   idxs[6] = glf[0].GenotypeIndex(transvers2, transvers2);
	   idxs[7] = glf[0].GenotypeIndex(transition, transvers1);
	   idxs[8] = glf[0].GenotypeIndex(transition, transvers2);
	   idxs[9] = glf[0].GenotypeIndex(transvers1, transvers2);

	   priors[idxs[0]] = 1.0 - theta*1.5;
	   priors[idxs[1]] = theta * pTs;
	   priors[idxs[2]] = priors[idxs[3]] = theta * pTv;
	   priors[idxs[4]] = 0.5 * 0.9975 * theta * pTs;
	   priors[idxs[5]] = priors[idxs[6]] = 0.5 * 0.9975 * theta * pTv;
	   priors[idxs[7]] = priors[idxs[8]] = priors[idxs[9]] = 0.5 * 0.0025 * theta / 3.;

	   for(int i=0; i < n; ++i) {
	     lks = glf[i].GetLikelihoods(newPos0);
	     maxpost = 0;
	     imaxpost = 0;
	     sum = 0;
	     for(int j=0; j < 10; ++j) {
	       sum += (posts[j] = priors[j] * lks[j]);
	       if ( maxpost < posts[j] ) {
		 maxpost = posts[j];
		 imaxpost = j;
	       }
	     }

	     threshold = sum * posterior;
	     if ( ( posts[imaxpost] > threshold ) && ( imaxpost != homRef ) ) {
	       al1 = allele1s[imaxpost];
	       al2 = allele2s[imaxpost];
	       
	       if ( al1 != refBase ) {
		 for(int j=0; j < 3; ++j) {
		   if ( altBases[j] == al1 ) break;
		   else if ( altBases[j] == 0 ) {
		     altBases[j] = al1;
		     break;
		   }
		 }
	       }
	       if ( al2 != refBase ) {
		 for(int j=0; j < 3; ++j) {
		   if ( altBases[j] == al2 ) break;
		   else if ( altBases[j] == 0 ) {
		     altBases[j] = al2;
		     break;
		   }
		 }
	       }
	     }
	   }

	   if ( altBases[0] == 0 ) continue;
	 }
	 else {
	   // Calculate maximum likelihood for a variant
	   if (smartFilter) {
	     double anyVariant = log(prior) + FilteringLikelihood(lkFilter, n, newPos0, refBase);
	     if (exp(lRef - anyVariant) > (1.0 - posterior)/posterior) {
	       smartFilterHits++;
	       continue;
	     }
	   }
	   
	   // Calculate likelihoods for the most likelily SNP configurations
	   double refTransition = log(prior * pTs) + PolymorphismLikelihood(lkGeno, n, newPos0, refBase, transition);
	   double refTransvers1 = log(prior * pTv) + PolymorphismLikelihood(lkGeno, n, newPos0, refBase, transvers1);
	   double refTransvers2 = log(prior * pTv) + PolymorphismLikelihood(lkGeno, n, newPos0, refBase, transvers2);
	   
	   // Calculate likelihoods for less likely SNP configurations
	   double transitiontv1 = log(prior * 0.001) + PolymorphismLikelihood(lkGeno, n, newPos0, transition, transvers1);
	   double transitiontv2 = log(prior * 0.001) + PolymorphismLikelihood(lkGeno, n, newPos0, transition, transvers2);
	   double transvers1tv2 = log(prior * 0.001) + PolymorphismLikelihood(lkGeno, n, newPos0, transvers1, transvers2);
	   
	   // Calculate the likelihood for unusual configurations where everyone is heterozygous ...
	   double sink = n > 10 ? log(prior * 1e-8) + SinkLikelihood(glf, n, newPos0) : -1e100;
	   
	   double lmax = max(
			     max(max(lRef, refTransition),max(refTransvers1, refTransvers2)),
			     max(max(transitiontv1, transitiontv2), max(transvers1tv2, sink)));
	   
	   double sum = exp(lRef - lmax) + exp(refTransition -lmax) +
	     exp(refTransvers1 - lmax) + exp(refTransvers2 - lmax) +
	     exp(transitiontv1 - lmax) + exp(transitiontv2 - lmax) +
	     exp(transvers1tv2 - lmax) + exp(sink - lmax);
	   
	   if (sum == 0.0) continue;
	   
	   // if not pass the SNP call threshold
	   if (exp(lRef - lmax)/sum > 1.0 - prior) {
	     if (filter.Length() == 0) homozygousReference++;
	     continue;
	   }
	   
	   //quality = 1.0 - exp(lRef - lmax) / sum;
	   
	   if (exp(refTransition - lmax)/sum > posterior)
	     altBases[0] = transition;
	   else if (exp(refTransvers1 - lmax)/sum > posterior)
	     altBases[0] = transvers1;
	   else if (exp(refTransvers2 - lmax)/sum > posterior)
	     altBases[0] = transvers2;
	   else if (exp(transitiontv1 - lmax)/sum > posterior) {
	     altBases[0] = transition;
	     altBases[1] = transvers1;
	   }
	   else if (exp(transitiontv2 - lmax)/sum > posterior) {
	     altBases[0] = transition;
	     altBases[1] = transvers1;
	   }
	   else if (exp(transvers1tv2 - lmax)/sum > posterior) {
	     altBases[0] = transvers1;
	     altBases[1] = transvers2;
	   }
	   else if (exp(sink - lmax)/sum > posterior)
            sinkFilter++;
	 }
       }

       if ( ( altBases[0] != 0 ) && ( newPos0 > 0 ) ) {
	 //fprintf(stderr,"%d %d %d %d %d\n", newPos0, refBase, altBases[0], altBases[1], altBases[2]);
	 int priorAN = 0;
	 int priorACs[3] = {0,0,0};

	 if ( inKeys ) {
	   priorAN = keys[keyCursor].priorAN;
	   priorACs[0] = keys[keyCursor].priorACs[0];
	   priorACs[1] = keys[keyCursor].priorACs[1];
	   priorACs[2] = keys[keyCursor].priorACs[2];
	 }

	 lkFull.SetAlleles(refBase, altBases);
	 double lFull = 0-lkFull.OptimizeFrequency(priorAN, priorACs);

	 // Posterior = Pr(SNP) = Pr(Data|Full)Pr(Full) + Pr(Data|Ref)Pr(Ref)
	 //                     = Pr(Data|Full)[Pr(Full) + Pr(Ref)(Pr(Data|Ref)/Pr(Data|Full))]
	 // lFull / [ prior * lFull + lRef ]
	 // 1 / [ prior + lRef/lFull ]
	 // exp(lRef) / [ prior * exp(lFull) + exp(lRef) ]
	 // 1 / [ prior * exp(lFull-lRef) + 1 ]
         // 1 / ( prior + exp(lRef-
	 double log10post = (lFull-lRef > 100) ? 0-log10(prior)-(lFull-lRef)/log(10) : 0-log10( prior * exp(lFull-lRef) + 1.0 );

	 ReportSNP(lkFull, n, newPos0, refBase, altBases, filter, totalDepth, rmsMapQuality, log10post);
       }

       //if ( newPos0 % 200 == 10 ) break;

       if ( inKeys ) ++keyCursor;
     }

     /*

     int actualBases = numEntries - baseCounts[0];

     printf("          Missing bases = %9d (%.3f%%)\n",
            baseCounts[0], baseCounts[0] * 100. / numEntries);
     printf("        Reference bases = %9d (%.3f%%)\n",
            numEntries - baseCounts[0], (numEntries - baseCounts[0]) * 100. / numEntries);
     
     printf("              A/T bases = %9d (%.3f%%, %d A, %d T)\n",
	    baseCounts[1] + baseCounts[4],
            (baseCounts[1] + baseCounts[4]) * 100. / actualBases,
	    baseCounts[1], baseCounts[4]);
     
     printf("              G/C bases = %9d (%.3f%%, %d G, %d C)\n",
	    baseCounts[3] + baseCounts[2],
            (baseCounts[3] + baseCounts[2]) * 100. / actualBases,
	    baseCounts[3], baseCounts[2]);
     
     printf("           Depth Filter = %9d bases (%.3f%%)\n",
	    depthFilter, depthFilter * 100. / actualBases);
     
     printf("     Map Quality Filter = %9d bases (%.3f%%)\n",
	    mapQualityFilter, mapQualityFilter * 100. / actualBases);
     
     printf("        Non-Polymorphic = %9d bases (%.3f%%)\n",
	    homozygousReference, homozygousReference * 100. / actualBases);
     
     printf("            Transitions = %9d bases (%.3f%%)\n",
	    transitions, transitions * 100. / actualBases);
     
     printf("          Transversions = %9d bases (%.3f%%)\n",
	    transversions, transversions * 100. / actualBases);
     
     printf("    Other Polymorphisms = %9d bases (%.3f%%)\n",
	    otherPolymorphisms, otherPolymorphisms * 100. / actualBases);
     */
   }

   if (baseCalls != NULL)
     fclose(baseCalls);
   
   time(&t);
   printf("\nAnalysis completed on %s\n", ctime(&t));
   fflush(stdout);
}

