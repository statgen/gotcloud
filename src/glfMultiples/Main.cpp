#include "BaseQualityHelper.h"
#include "GlfLikelihoods.h"
#include "StringArray.h"
#include "StringAlias.h"
#include "Parameters.h"
#include "Pedigree.h"
#include "Error.h"

#include <math.h>
#include <time.h>
#include <limits.h>

FILE * baseCalls = NULL;

class glFit {
public:
    double pHWE, pHWD1, pHWD2;
    double llkHWE, llkHWD;
    double inbreedingCoeff;
    int rounds;
    double signedLRT() { return (inbreedingCoeff > 0 ? 2 : -2 )*(llkHWD-llkHWE); }

    glFit(GenotypeLikelihood& lk, glfHandler * glf, int n, int position, int refAllele, int al1, int al2, int maxiter = 100, double eps=1e-6) {
        int geno11 = glfHandler::GenotypeIndex(al1, al1);
        int geno12 = glfHandler::GenotypeIndex(al1, al2);
        int geno22 = glfHandler::GenotypeIndex(al2, al2);

        //int label1 = al1 == refAllele ? 0 : 1;
        //int label2 = al2 == refAllele ? 0 : al1 == al2 ? label1 : label1 + 1;

        double p = .2 + rand()/(RAND_MAX+1.)*.6; // start from random but common AF
        double f0,f1,f2, fsum, sum, sum0, sum1, sum2;
        bool convE = false, convD = false;

        double q = 1.-p;
        double p0 = q * q;
        double p1 = 2. * p * q;
        double p2 = p * p;
        int i;

        for(rounds = 0; rounds < maxiter; ++rounds) {
            sum = sum0 = sum1 = sum2 = 0;

            for(i=0; i < n; ++i) {
                const double  * lks = glf[i].GetLikelihoods(position);
                if ( !convE ) {
                    f0 = q * q * lks[geno11];
                    f1 = 2. * p * q * lks[geno12];
                    f2 = p * p * lks[geno22];
                    fsum = f0+f1+f2; // sum_g Pr(g)Pr(Data|g)
                    //postE[i*3] = f0/fsum;
                    sum += f1/fsum; //(postE[i*3+1] = f1/fsum);
                    sum += (2. * f2/fsum); //(2 * (postE[i*3+2] = f2/fsum));
                }

                if ( !convD ) {
                    f0 = p0 * lks[geno11];
                    f1 = p1 * lks[geno12];
                    f2 = p2 * lks[geno22];
                    fsum = f0+f1+f2;
                    sum0 += f0/fsum; //(postD[i*3] = f0/fsum);
                    sum1 += f1/fsum; //(postD[i*3+1] = f1/fsum);
                    sum2 += f2/fsum; //(postD[i*3+2] = f2/fsum);
                }
            }

            if ( !convE ) {
                p = sum / (2*n);
                if ( fabs(p + q - 1.) < eps ) convE = true;
                q = 1.-p;
            }
            if ( !convD ) {
                if ( ( fabs(p1 - sum1/n) < eps ) && ( fabs(p2 - sum2/n) < eps ) ) convD = true;
                p0 = sum0 / (n);
                p1 = sum1 / (n);
                p2 = sum2 / (n);
            }
            if ( convE && convD ) break;
        }

        llkHWE = 0;
        llkHWD = 0;
        pHWE = p;
        pHWD1 = p1;
        pHWD2 = p2;
        double obsHET = 0;
        for(i=0; i < n; ++i) {
            const double* lks = glf[i].GetLikelihoods(position);

            f0 = q * q * lks[geno11];
            f1 = 2. * p * q * lks[geno12];
            f2 = p * p * lks[geno22];
            fsum = f0+f1+f2; // sum_g Pr(g)Pr(Data|g)
            llkHWE += log(fsum);

            f0 = p0 * lks[geno11];
            f1 = p1 * lks[geno12];
            f2 = p2 * lks[geno22];
            fsum = f0+f1+f2; // sum_g Pr(g)Pr(Data|g)
            llkHWD += log(fsum);
            obsHET += f1/fsum;
        }
        inbreedingCoeff = 1.-obsHET/(2.*p*q*n);
    }
};


void ReportDate(FILE * output)
   {
   if (output == NULL) return;

   time_t systemTime;
   time(&systemTime);

   tm * digestedTime;
   digestedTime = gmtime(&systemTime);

   fprintf(output, "##filedate=%04d%02d%02d\n", digestedTime->tm_year + 1900,
                                                digestedTime->tm_mon + 1,
                                                digestedTime->tm_mday);
   }

void DumpDetails(glfHandler * glf, int n, int position, int refBase)
   {
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

void ReportGenotypes(GenotypeLikelihood & lk, glfHandler * glf, int n,
                     int position, int refAllele, int al1, int al2,
                     String & info, String & genotypes)
   {
   info.Clear();
   genotypes.Clear();

   double priors[2][10];

   lk.GetFemalePriors(priors[0], lk.min);
   lk.GetMalePriors(priors[1], lk.min);

   int geno11 = glfHandler::GenotypeIndex(al1, al1);
   int geno12 = glfHandler::GenotypeIndex(al1, al2);
   int geno22 = glfHandler::GenotypeIndex(al2, al2);

   int label1 = al1 == refAllele ? 0 : 1;
   int label2 = al2 == refAllele ? 0 : al1 == al2 ? label1 : label1 + 1;

   int genoRR = 0;
   int genoR1 = 0;
   int genoR2 = 0;

   if (label2 == 2)
      {
      genoRR = glfHandler::GenotypeIndex(refAllele, refAllele);
      genoR1 = glfHandler::GenotypeIndex(refAllele, al1);
      genoR2 = glfHandler::GenotypeIndex(refAllele, al2);
      }

   String label11[2], label12[2], label22[2];

   if (lk.chromosomeType == CT_CHRY)
      label11[0] = label12[0] = label22[0] = ".";
   else if (lk.chromosomeType == CT_MITO)
      {
      label11[0].printf("%d", label1);
      label12[0] = ".";
      label22[0].printf("%d", label2);
      }
   else /* CT_AUTO, CT_CHRX */
      {
      label11[0].printf("%d/%d", label1, label1);
      label12[0].printf("%d/%d", label1, label2);
      label22[0].printf("%d/%d", label2, label2);
      }

   String maleLabel11, maleLabel12, maleLabel22;

   if (lk.chromosomeType != CT_AUTOSOME) /* CT_CHRY, CT_CHRX, CT_MITO */
      {
      label11[1].printf("%d", label1);
      label12[1] = ".";
      label22[1].printf("%d", label2);
      }
   else
      {
      label11[1].printf("%d/%d", label1, label1);
      label12[1].printf("%d/%d", label1, label2);
      label22[1].printf("%d/%d", label2, label2);
      }

   int ns         = 0;
   int ac[4]      = {0, 0, 0, 0};
   double Acount  = 0.5;
   double ABcount = 1.0;

   for (int i = 0; i < n; i++)
      {
      int sex = lk.sexes[i] == SEX_MALE ? 1 : 0;

      // Report on the best genotype for the current SNP model
      int quality = GetBestRatio(glf[i].GetLikelihoods(position), priors[sex]);
      int best = GetBestGenotype(glf[i].GetLikelihoods(position), priors[sex]);

      String & label = best == geno11 ? label11[sex] :
                       best == geno12 ? label12[sex] : label22[sex];
      bool    nocall = label[0] == '.';
      int     depth  = glf[i].GetDepth(position);

      genotypes.catprintf("\t%s:%d:%d",
               (const char *) label, depth, nocall ? 0 : quality);

      if (label[0] != '.')
         {
	   if ( depth > 0 ) {
	     ns++;
	     ac[label[0] - '0']++;
	   }

         if (label.Length() > 1 && label[2] != '.')
            {
	      if ( depth > 0 ) ac[label[2] - '0']++;

            const double  * likelihoods = glf[i].GetLikelihoods(position);
            const unsigned char * logLikelihoods = glf[i].GetLogLikelihoods(position);

            // Tom's Allele Balance Calculation (only in diploid samples)
            double pHet = priors[sex][geno12] * likelihoods[geno12] /
                         (priors[sex][geno11] * likelihoods[geno11] +
                          priors[sex][geno12] * likelihoods[geno12] +
                          priors[sex][geno22] * likelihoods[geno22] +
                          1e-30);

            if (pHet > 1e-5 && depth > 0)
               {
               int scale = logLikelihoods[geno22] + logLikelihoods[geno11]
                         - 2 * logLikelihoods[geno12] + 6 * depth;
               int minimum = abs(logLikelihoods[geno22] - logLikelihoods[geno11]);

               if (scale < 4) scale = 4;
               if (scale < minimum) scale = minimum;

               double delta = (logLikelihoods[geno22] - logLikelihoods[geno11])
                               / (scale + 1e-30);
               double nref = 0.5 * depth * (1.0 + delta);

               Acount += pHet * nref;
               ABcount += pHet * depth;
               }
            }
         }

      if (label1 == 0 && label2 == 0)
         continue;

      if (label2 < 2)
         genotypes.catprintf(":%d,%d,%d",
                  glf[i].GetLogLikelihoods(position)[geno11],
                  glf[i].GetLogLikelihoods(position)[geno12],
                  glf[i].GetLogLikelihoods(position)[geno22]);
      else
         genotypes.catprintf(":%d,%d,%d,%d,%d,%d",
                  glf[i].GetLogLikelihoods(position)[genoRR],
                  glf[i].GetLogLikelihoods(position)[genoR1],
                  glf[i].GetLogLikelihoods(position)[geno11],
                  glf[i].GetLogLikelihoods(position)[genoR2],
                  glf[i].GetLogLikelihoods(position)[geno12],
                  glf[i].GetLogLikelihoods(position)[geno22]);
      }
   double AB = Acount / (ABcount + 1e-30);
   double AZ = (Acount - 0.5*ABcount)/sqrt(ABcount*0.25 + 1e-30);

   info.catprintf("NS=%d", ns);
   info.catprintf(";AN=%d", ac[0] + ac[1] + ac[2] + ac[3]);

   if (label1 == 0 && label2 == 0)
      return;

   if (label2 < 2)
      {
      info.catprintf(";AC=%d", ac[1]);
      info.catprintf(";AF=%.6lf", 1. - lk.min);
      }
   else
      {
      info.catprintf(";AC=%d,%d", ac[1], ac[2]);
      info.catprintf(";AF=%.6lf,%.6lf", lk.min, 1. - lk.min);
      }

    info.catprintf(";AB=%.4lf;AZ=%.4lf", AB, AZ);

    glFit gFit(lk, glf, n, position, refAllele, al1, al2);
    info.catprintf(";FIC=%.4lf;SLRT=%.4lf;HWEAF=%.4lf;HWDAF=%.4lf,%.4lf",gFit.inbreedingCoeff,gFit.signedLRT(),gFit.pHWE,gFit.pHWD1,gFit.pHWD2);
   }

void ReportSNP(GenotypeLikelihood & lk,
                  int n, int position,
                  int refBase, int allele1, int allele2,
                  const char * filter,
                  int totalCoverage, int rmsMapQuality, double posterior)
   {
   if (baseCalls == NULL) return;

   if (allele2 == refBase)
      {
      int swap = allele1;
      allele1 = allele2;
      allele2 = swap;
      }

   char alleles[] = { 0, 'A', 'C', 'G', 'T' };

   glfHandler * glf = lk.glf;

   // Find the location of the first non-stub glf
   int firstGlf = 0;
   while (glf[firstGlf].isStub)
      firstGlf++;

   // #Chrom   Pos   Id
   fprintf(baseCalls, "%s\t%d\t.\t", (const char *) glf[firstGlf].label, position + 1);

   // Reference allele
   int nalleles = 1;
   fprintf(baseCalls, "%c\t", alleles[refBase]);

   // Other alleles
   if (allele1 != refBase)
      fprintf(baseCalls, "%c", alleles[allele1]), nalleles++;

   if (allele2 != refBase && allele2 != allele1)
      fprintf(baseCalls, "%s%c", nalleles > 1 ? "," : "", alleles[allele2]), nalleles++;

   if (nalleles == 1)
      fprintf(baseCalls, ".");

   fprintf(baseCalls, "\t");

   int quality = posterior > 0.9999999999 ? 100 : -10 * log10(1.0 - posterior);

   // Quality for this call
   fprintf(baseCalls, "%d\t", quality);

   // Filter for this call
   fprintf(baseCalls, "%s\t", filter == NULL || filter[0] == 0 ? "PASS" : filter);

   // Find best frequency
   lk.SetAlleles(allele1, allele2);
   lk.OptimizeFrequency();

   String info, genotypes;

   ReportGenotypes(lk, glf, n, position, refBase, allele1, allele2, info, genotypes);

   // Information for this call
   fprintf(baseCalls, "DP=%d;MQ=%d;", totalCoverage, rmsMapQuality);
   fprintf(baseCalls, "%s\t", (const char *) info);

   // Format for this call
   fprintf(baseCalls, "GT:DP:GQ");

   fprintf(baseCalls, ":PL");

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


int main(int argc, char ** argv)
   {
   printf("glfMultiples -- SNP calls based on .glf or .glz files\n");
   printf("(c) 2008-2013 Goncalo Abecasis, Sebastian Zoellner, Yun Li\n\n");

   String pedfile;
   String positionfile;
   String callfile;
   String glfAliases;
   String region;
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
      LONG_PARAMETER_GROUP("Map Quality Filter")
         LONG_INTPARAMETER("minMapQuality", &minMapQuality)
         LONG_PARAMETER("strict", &mapQualityStrict)
      LONG_PARAMETER_GROUP("Total Depth Filter")
         LONG_INTPARAMETER("minDepth", &minTotalDepth)
         LONG_INTPARAMETER("maxDepth", &maxTotalDepth)
      LONG_PARAMETER_GROUP("Position Filter")
         LONG_STRINGPARAMETER("positionFile", &positionfile)
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

   if (posterior < 0.50)
      error("Posterior threshold for genotype calls (-p option) must be > 0.50.");

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
   for (int i = 1; i <= 2 * n; i++)
      prior += 1.0 / i;
   prior *= theta;

   glfHandler * glf = new glfHandler[n];

   int firstGlf = n;
   if (ped.count)
      {
      bool warn = false;

      bool anyOpened = false;

      for (int i = n - 1; i >= 0; i--)
         if (!glf[i].Open(ped[i].strings[0]))
            {
            printf("Failed to open genotype likelihood file [%s] for individual %s:%s\n",
                   (const char *) ped[i].strings[0],
                   (const char *) ped[i].famid,
                   (const char *) ped[i].pid);

            glf[i].OpenStub();
            }
         else
         {
             anyOpened = true;
             if(ifeof(glf[i].handle) != 0)
             {
                 // Empty GLF (just header).
                 // Close it and open a stub.
                 warning("GLF file '%s' appears empty ...\n",
                         ped.count ? (const char *) ped[i].strings[0] : argv[i]);
                 glf[i].Close();
                 glf[i].OpenStub();
             }
             else
             {
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

   if (baseCalls != NULL)
      {
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
   // format chr:position
   StringArray buffer, tokens, tokens2;
   StringIntMap positionMap; // value contains 4 bytes : 0 [AL2] [AL1] [REF]

   buffer.Read(positionfile);

   for (int i = 0; i < buffer.Length(); i++)
   {
      tokens.ReplaceTokens(buffer[i], " \t");

      if (tokens.Length() < 2) continue;

      if ( tokens.Length() < 5 ) { // [CHROM] [POS] [ID] [REF] [ALT]
	positionMap.Add(tokens[0]+":"+(int(tokens[1].AsInteger() - 1)),0);
	//positions.Add(tokens[0] + ":" + (int(tokens[1].AsInteger() - 1)));
      }
      else if ( tokens.Length() >= 5 ) {
	int val = 0;
	val |= ((0x00ff) & tokens[3][0]);
	if ( tokens[4].Length() == 1 ) {
	  val |= ( ((0x00ff) & tokens[4][0]) << 8);
	}
	else {
	  tokens2.ReplaceColumns(tokens[4],',');
	  val |= ( ((0x00ff) & tokens2[0][0]) << 16);
	  val |= ( ((0x00ff) & tokens2[1][0]) << 24);
	}
	positionMap.Add(tokens[0]+":"+(int(tokens[1].AsInteger() - 1)),val);
      }
   }

   // Prepare GenotypeLikelihood calculator, which will use sex information,
   // if available
   GenotypeLikelihood lkGeno(n, glf);
   FilterLikelihood lkFilter(n, glf);

   lkGeno.glf = lkFilter.glf = glf;
   lkGeno.n = lkFilter.n = n;

   if (ped.count)
      for (int i = 0; i < ped.count; i++)
         lkGeno.sexes[i] = lkFilter.sexes[i] = ped[i].sex == SEX_MALE ? SEX_MALE : SEX_FEMALE;

   int chromosomeType = 0;

   // Main loop, which iterates through chromosomes and then positions
   while (glf[firstGlf].NextSection())
      {
      for (int i = firstGlf + 1; i < n; i++)
         {
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

         if (glf[firstGlf].maxPosition != glf[i].maxPosition || glf[firstGlf].label != glf[i].label)
            {
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
      if(!region.IsEmpty())
      {
          if(glf[firstGlf].label != regionChr)
          {
              continue;
          }
      }
      


      chromosomeType = CT_AUTOSOME;

      if (ped.count)
         {
         if (glf[firstGlf].label == xLabel) chromosomeType = CT_CHRX;
         if (glf[firstGlf].label == yLabel) chromosomeType = CT_CHRY;
         if (glf[firstGlf].label == mitoLabel) chromosomeType = CT_MITO;
         }
      
      int endPos = glf[firstGlf].maxPosition;
      if((regionEnd != -1) && (regionEnd < endPos))
      {
          endPos = regionEnd;
      }
      int numEntries = endPos - regionStart;
      printf("Processing section %s with %d entries\n",
             (const char *) glf[firstGlf].label, numEntries);

      int refBase = 0;
      int position = 0;
      int mapQualityFilter = 0;
      int depthFilter = 0;
      int homozygousReference = 0;
      int transitions = 0;
      int transversions = 0;
      int otherPolymorphisms = 0;
      int sinkFilter = 0;
      int smartFilterHits = 0;
      int baseCounts[5] = {0, 0, 0, 0, 0};

      String filter;

      while (true)
         {
         if (position > 0)
            {
            // Check whether we have reached the end of the current chromosome
            bool done = true;
            for (int i = 0; i < n; i++)
               if (glf[i].data.recordType != 0)
                  done = false;
               if (done) break;
               }

         // Advance to the next position where needed
         int newPosition = glf[firstGlf].maxPosition + 1;
         for (int i = 0; i < n; i++)
         {
            if (glf[i].position == position)
            {
               glf[i].NextBaseEntry();
            }
            if(newPosition > glf[i].position)
            {
                newPosition = glf[i].position;
                refBase = glf[i].data.refBase;
            }
         }

         position = newPosition;
         if(position < regionStart)
         {
             // Not yet to the region start, so keep incrementing.
             continue;
         }
         // Figure out the current analysis position
         refBase = glf[0].data.refBase;
         position = glf[0].position;
         for (int i = 1; i < n; i++)
            if (position > glf[i].position)
               {
               position = glf[i].position;
               refBase = glf[i].data.refBase;
               }

         // Avoid alignments that extend past the end of the chromosome
         if (position >= endPos)
            break;

         baseCounts[refBase]++;

         // These lines can be uncommented for debugging purposes
         // for (int i = 0; i < n; i++)
         //   printf("GLF %d : position %d, refBase %d\n", i, position, refBase);
         // printf("Position: %d, refBase: %d\n", position, refBase);

         //if (positions.Entries())
	 if ( positionMap.Length() ) {
	   filter = glf[firstGlf].label + ":" + position;

	   //if (positionsFind(filter) < 0) continue;
	   if (positionMap.Find(filter) < 0) continue;
	 }

         if (refBase == 0) continue;

         filter.Clear();

         int     totalDepth = 0, nSamplesCovered = 0;
         double  rmsMapQuality = 0.0;
         bool    passMapQualityFilter = false;

         for (int i = 0; i < n; i++) {
	   int depth = glf[i].GetDepth(position);

	   if (depth > 0) {
	     totalDepth += depth;
	     nSamplesCovered++;
	     
	     int mapQuality = glf[i].GetMapQuality(position);
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

         // Calculate likelihood assuming every is homozygous for the reference
         double lRef = log(1.0 - prior);
         for (int i = 0; i < n; i++)
            lRef += log(glf[i].GetLikelihoods(position)[homRef]);

         // Figure out the correct type of analysis
         lkGeno.position = lkFilter.position = position;
         lkGeno.chromosomeType = lkFilter.chromosomeType =
            chromosomeType != CT_CHRX ?
               chromosomeType :
               position >= xStart && position <= xStop ? CT_CHRX : CT_AUTOSOME;

         // Calculate maximum likelihood for a variant
         if (smartFilter) {
	   double anyVariant = log(prior) + FilteringLikelihood(lkFilter, n, position, refBase);
	   if (exp(lRef - anyVariant) > (1.0 - posterior)/posterior) {
	     smartFilterHits++;
	     continue;
	   }
	 }

         // Transition / Transversion rate prior
         double pTs = uniformTsTv ? 1./3. : 2./3.;
         double pTv = uniformTsTv ? 1./3. : 1./6.;

         // Calculate likelihoods for the most likelily SNP configurations
         double refTransition = log(prior * pTs) + PolymorphismLikelihood(lkGeno, n, position, refBase, transition);
         double refTransvers1 = log(prior * pTv) + PolymorphismLikelihood(lkGeno, n, position, refBase, transvers1);
         double refTransvers2 = log(prior * pTv) + PolymorphismLikelihood(lkGeno, n, position, refBase, transvers2);

         // Calculate likelihoods for less likely SNP configurations
         double transitiontv1 = log(prior * 0.001) + PolymorphismLikelihood(lkGeno, n, position, transition, transvers1);
         double transitiontv2 = log(prior * 0.001) + PolymorphismLikelihood(lkGeno, n, position, transition, transvers2);
         double transvers1tv2 = log(prior * 0.001) + PolymorphismLikelihood(lkGeno, n, position, transvers1, transvers2);

         // Calculate the likelihood for unusual configurations where everyone is heterozygous ...
         double sink = n > 10 ? log(prior * 1e-8) + SinkLikelihood(glf, n, position) : -1e100;

         double lmax = max(
               max(max(lRef, refTransition),max(refTransvers1, refTransvers2)),
               max(max(transitiontv1, transitiontv2), max(transvers1tv2, sink)));

         double sum = exp(lRef - lmax) + exp(refTransition -lmax) +
                      exp(refTransvers1 - lmax) + exp(refTransvers2 - lmax) +
                      exp(transitiontv1 - lmax) + exp(transitiontv2 - lmax) +
                      exp(transvers1tv2 - lmax) + exp(sink - lmax);

         if (sum == 0.0) continue;

	 // if not pass the SNP call threshold
         if (exp(lRef - lmax)/sum > 1.0 - prior)
            {
            if (filter.Length() == 0) homozygousReference++;

	    if ( positionMap.Length() ) {
	      //if (positions.Entries())
               ReportSNP(lkGeno, n, position, refBase, refBase, refBase, filter, totalDepth, rmsMapQuality, lRef / sum);
	    }

            continue;
            }

         double quality = 1.0 - exp(lRef - lmax) / sum;

         if (verbose)
            {
            DumpDetails(glf, n, position, refBase);

            printf("%.3f %.3f %.3f %.3f %.3f %.3f %.3f\n",
                 lRef, refTransition, refTransvers1, refTransvers2,
                 transitiontv1, transitiontv2, transvers1tv2);
            }

         if (exp(refTransition - lmax)/sum > posterior)
            {
            ReportSNP(lkGeno, n, position, refBase, refBase, transition,
                      filter, totalDepth, rmsMapQuality, quality /* refTransition/sum */);
            if (filter.Length() == 0) transitions++;
            }
         else if (exp(refTransvers1 - lmax)/sum > posterior)
            {
            ReportSNP(lkGeno, n, position, refBase, refBase, transvers1,
                      filter, totalDepth, rmsMapQuality, quality /* refTransvers1/sum */);
            if (filter.Length() == 0) transversions++;
            }
         else if (exp(refTransvers2 - lmax)/sum > posterior)
            {
            ReportSNP(lkGeno, n, position, refBase, refBase, transvers2,
                      filter, totalDepth, rmsMapQuality, quality /* refTransvers2/sum */);
            if (filter.Length() == 0) transversions++;
            }
         else if (exp(transitiontv1 - lmax)/sum > posterior)
            {
            ReportSNP(lkGeno, n, position, refBase, transition, transvers1,
                      filter, totalDepth, rmsMapQuality, quality /* transitiontv1/sum */);
            if (filter.Length() == 0) otherPolymorphisms++;
            }
         else if (exp(transitiontv2 - lmax)/sum > posterior)
            {
            ReportSNP(lkGeno, n, position, refBase, transition, transvers2,
                      filter, totalDepth, rmsMapQuality, quality /* transitiontv2/sum */);
            if (filter.Length() == 0) otherPolymorphisms++;
            }
         else if (exp(transvers1tv2 - lmax)/sum > posterior)
            {
            ReportSNP(lkGeno, n, position, refBase, transvers1, transvers2,
                      filter, totalDepth, rmsMapQuality, quality /* transvers1tv2/sum */);
            if (filter.Length() == 0) otherPolymorphisms++;
            }
         else if (exp(sink - lmax)/sum > posterior)
            sinkFilter++;
         }

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

      if (n > 10)
          printf("          Homology Sink = %9d bases (%.3f%%)\n",
                 sinkFilter, sinkFilter * 100. / actualBases);

      if (smartFilter)
          printf("           Smart Filter = %9d bases (%.3f%%)\n",
                 smartFilterHits, smartFilterHits * 100. / actualBases);

      int noCalls = actualBases - homozygousReference - transitions - transversions - otherPolymorphisms - sinkFilter;
      printf("                No call = %9d bases (%.3f%%)\n",
            noCalls, noCalls * 100. / actualBases);

      fflush(stdout);
      }

   if (baseCalls != NULL)
      fclose(baseCalls);

   time(&t);
   printf("\nAnalysis completed on %s\n", ctime(&t));
   fflush(stdout);
   }


