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

int char2IntBase(char c) {
  switch(c) {
  case 'A':
    return 1;
  case 'C':
    return 2;
  case 'G':
    return 3;
  case 'T':
    return 4;
  default:
    fprintf(stderr,"Cannot recognize base %c\n",c);
    error("Incompatible VCF format");
    return 0;
  }
}

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

   int genoRR = 0, genoR1 = 0, genoR2 = 0;

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

   info.catprintf(";AB=%.4lf", AB);
   }

void ReportSNP(GenotypeLikelihood & lk,
                  int n, int position,
                  int refBase, int allele1, int allele2,
                  const char * filter,
                  int totalCoverage, int rmsMapQuality, double quality)
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

   //int quality = posterior > 0.9999999999 ? 100 : -10 * log10(1.0 - posterior);

   // Quality for this call
   fprintf(baseCalls, "%.0lf\t", quality);

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
   fprintf(baseCalls, "GT:GD:GQ");

   if (allele2 != refBase || allele1 != refBase)
      fprintf(baseCalls, ":PL%s", allele1 == refBase ? "" : "3");

   fprintf(baseCalls, "%s\n", (const char *) genotypes);
   }

int main(int argc, char ** argv) {
   printf("glfExtract -- Extract VCF based on .glf or .glz files\n");
   printf("(c) 2008-2011 Goncalo Abecasis, Hyun Min Kang\n\n");

   String pedfile;
   String invcf;
   String callfile;
   String glfAliases;
   ParameterList pl;

   bool   verbose = false;
   String xLabel("X"), yLabel("Y"), mitoLabel("MT");
   int    xStart = 2699520, xStop = 154931044;

   BEGIN_LONG_PARAMETERS(longParameters)
      LONG_PARAMETER_GROUP("Pedigree File")
         LONG_STRINGPARAMETER("ped", &pedfile)
      LONG_PARAMETER_GROUP("Position Filter")
         LONG_STRINGPARAMETER("invcf", &invcf)
      LONG_PARAMETER_GROUP("Chromosome Labels")
         LONG_STRINGPARAMETER("xChr", &xLabel)
         LONG_STRINGPARAMETER("yChr", &yLabel)
         LONG_STRINGPARAMETER("mito", &mitoLabel)
         LONG_INTPARAMETER("xStart", &xStart)
         LONG_INTPARAMETER("xStop", &xStop)
      LONG_PARAMETER_GROUP("Output")
         LONG_PARAMETER("verbose", &verbose)
      LONG_PARAMETER_GROUP("Sample Names")
         LONG_STRINGPARAMETER("glfAliases", &glfAliases)
   END_LONG_PARAMETERS();

   pl.Add(new StringParameter('b', "Base Call File", callfile));
   pl.Add(new LongParameters("Additional Options", longParameters));
   int argstart = pl.ReadWithTrailer(argc, argv) + 1;
   pl.Status();

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

   glfHandler * glf = new glfHandler[n];

   int firstGlf = n;
   if (ped.count) {
      bool warn = false;

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
            firstGlf = i;

      if (warn)
         printf("\n");

      if (firstGlf == n)
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

   printf("Generating VCFs for files ...\n");
   for (int i = 0; i < n; i++)
      printf("%s\n", ped.count ? (const char *) ped[i].strings[0] : argv[i]);
   printf("\n");

   baseCalls = fopen(callfile, "wt");

   if (baseCalls != NULL)
      {
      fprintf(baseCalls, "##fileformat=VCFv4.1\n");
      ReportDate(baseCalls);
      fprintf(baseCalls, "##source=glfExtract\n");
      fprintf(baseCalls, "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Total Depth at Site\">\n");
      fprintf(baseCalls, "##INFO=<ID=MQ,Number=1,Type=Integer,Description=\"Root Mean Squared Mapping Quality\">\n");
      fprintf(baseCalls, "##INFO=<ID=NS,Number=1,Type=Integer,Description=\"Number of Samples With Coverage\">\n");
      fprintf(baseCalls, "##INFO=<ID=AN,Number=1,Type=Integer,Description=\"Number of Alleles in Samples with Coverage\">\n");
      fprintf(baseCalls, "##INFO=<ID=AC,Number=.,Type=Integer,Description=\"Alternate Allele Counts in Samples with Coverage\">\n");
      fprintf(baseCalls, "##INFO=<ID=AF,Number=.,Type=Float,Description=\"Alternate Allele Frequencies\">\n");
      fprintf(baseCalls, "##INFO=<ID=AB,Number=1,Type=Float,Description=\"Allele Balance in Heterozygotes\">\n");
      fprintf(baseCalls, "##FORMAT=<ID=DP,Number=1,Type=Integer,Description=\"Read Depth\">\n");
      fprintf(baseCalls, "##FORMAT=<ID=PL,Number=3,Type=Integer,Description=\"Genotype Likelihoods for Genotypes 0/0,0/1,1/1\">\n");
      fprintf(baseCalls, "##FORMAT=<ID=PL3,Number=6,Type=Integer,Description=\"Genotype Likelihoods for Genotypes 0/0,0/1,1/1,0/2,1/2,2/2\">\n");
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
   String buffer;
   StringArray vcfTokens, tokens2;
   //StringIntMap positionMap; // value contains 4 bytes : 0 [AL2] [AL1] [REF]

   String curChrom;
   int curPos, chromosomeType;
   GenotypeLikelihood lkGeno(n, glf);

   lkGeno.glf = glf;
   lkGeno.n = n;

   IFILE vcfFile = ifopen(invcf,"rb");

   if (ped.count)
      for (int i = 0; i < ped.count; i++)
         lkGeno.sexes[i] = ped[i].sex == SEX_MALE ? SEX_MALE : SEX_FEMALE;
   
   while( buffer.ReadLine(vcfFile) > 0 ) {
     if ( buffer[0] == '#' ) 
       continue;

     else {
       vcfTokens.ReplaceColumns(buffer, '\t');
       if ( vcfTokens.Length() < 8 )
         error("Input VCF file needs to have at least 8 columns");

       int refBase = char2IntBase(vcfTokens[3][0]);
       int allele1, allele2;
       if ( vcfTokens[4].Length() == 1 ) {
	 allele1 = refBase;
	 allele2 = char2IntBase(vcfTokens[4][0]);
       }
       else {
	 tokens2.ReplaceColumns(vcfTokens[4],',');
	 allele1 = char2IntBase(tokens2[0][0]);
	 allele2 = char2IntBase(tokens2[1][0]);
       }

       curPos = vcfTokens[1].AsInteger()-1;
       if ( curChrom.Compare(vcfTokens[0]) != 0 ) {
	 curChrom = vcfTokens[0];
	 for(int i=firstGlf; i < n; ++i) {
	   if ( glf[i].isStub ) continue;
	   glf[i].NextSection();  // need to check whether the label matches
	   if ( curChrom.Compare(glf[i].label) != 0 )
	     error("Chromosome Name does not match");
	 }

	 chromosomeType = CT_AUTOSOME;
	 
	 if (ped.count) {
	   if (curChrom == xLabel) chromosomeType = CT_CHRX;
	   if (curChrom == yLabel) chromosomeType = CT_CHRY;
	   if (curChrom == mitoLabel) chromosomeType = CT_MITO;
	 }
	 
	 printf("Processing section %s with %d entries\n",
		(const char *) glf[firstGlf].label, glf[firstGlf].maxPosition);
       }

       for(int i=firstGlf; i < n; ++i) {
	 while( glf[i].position < curPos )
	   glf[i].NextBaseEntry();
       }

       int     totalDepth = 0, nSamplesCovered = 0;
       double  rmsMapQuality = 0.0;
       for (int i = 0; i < n; i++) {
	 int depth = glf[i].GetDepth(curPos);
	 
	 if (depth > 0) {
	   totalDepth += depth;
	   nSamplesCovered++;
	   
	   int mapQuality = glf[i].GetMapQuality(curPos);
	   rmsMapQuality += depth * mapQuality * mapQuality;
	 }
       }
       rmsMapQuality = sqrt(rmsMapQuality / (totalDepth + 1e-15));

       lkGeno.position = curPos;
       lkGeno.chromosomeType = chromosomeType != CT_CHRX ? chromosomeType :
               curPos >= xStart && curPos <= xStop ? CT_CHRX : CT_AUTOSOME;

       ReportSNP(lkGeno, n, curPos, refBase, allele1, allele2,
		 vcfTokens[6], totalDepth, rmsMapQuality, vcfTokens[5].AsDouble()); 
     }
   }

   if (baseCalls != NULL)
      fclose(baseCalls);

   time(&t);
   printf("\nAnalysis completed on %s\n", ctime(&t));
   fflush(stdout);
}
