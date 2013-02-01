#include "GlfLikelihoods.h"

GenotypeLikelihood::GenotypeLikelihood(int count, glfHandler * glfPointers)
   {
   n = count;
   glf = glfPointers;

   sexes = new char [n];

   for (int i = 0; i < n; i++)
      sexes[i] = SEX_FEMALE;

   chromosomeType = CT_AUTOSOME;
   }

GenotypeLikelihood::~GenotypeLikelihood()
   {
   if (sexes != NULL)
      delete [] sexes;
   }

void GenotypeLikelihood::SetAlleles(int al1, int al2)
   {
   allele1 = al1;
   allele2 = al2;

   geno11 = glfHandler::GenotypeIndex(allele1, allele1);
   geno12 = glfHandler::GenotypeIndex(allele1, allele2);
   geno22 = glfHandler::GenotypeIndex(allele2, allele2);
   }

double GenotypeLikelihood::Evaluate(double freq)
   {
   double prior11 = freq * freq;
   double prior12 = freq * (1.0 - freq) * 2.0;
   double prior22 = (1.0 - freq) * (1.0 - freq);

   double prior1 = freq;
   double prior2 = 1.0 - freq;

   double likelihood = 0.0;

   switch (chromosomeType)
      {
      case CT_MITO :
         prior11 = prior1;
         prior12 = 0.0;
         prior22 = prior2;
      case CT_AUTOSOME :
         for (int i = 0; i < n; i++)
            likelihood += log(prior11 * glf[i].GetLikelihoods(position)[geno11] +
                              prior12 * glf[i].GetLikelihoods(position)[geno12] +
                              prior22 * glf[i].GetLikelihoods(position)[geno22] +
                              1e-30);
            break;
      case CT_CHRY :
         for (int i = 0; i < n; i++)
            if (sexes[i] == SEX_MALE)
               likelihood += log(prior1 * glf[i].GetLikelihoods(position)[geno11] +
                                 prior2 * glf[i].GetLikelihoods(position)[geno22] +
                                 1e-30);
            break;
      case CT_CHRX :
         for (int i = 0; i < n; i++)
            if (sexes[i] == SEX_MALE)
               likelihood += log(prior1 * glf[i].GetLikelihoods(position)[geno11] +
                                 prior2 * glf[i].GetLikelihoods(position)[geno22] +
                                 1e-30);
            else
               likelihood += log(prior11 * glf[i].GetLikelihoods(position)[geno11] +
                                 prior12 * glf[i].GetLikelihoods(position)[geno12] +
                                 prior22 * glf[i].GetLikelihoods(position)[geno22] +
                                 1e-30);
      }


   return likelihood;
   }

void GenotypeLikelihood::GetPriors(double * priors, double freq, int i)
   {
   if (sexes[i] == SEX_MALE)
      GetMalePriors(priors, freq);
   else
      GetFemalePriors(priors, freq);
   }

void GenotypeLikelihood::GetMalePriors(double * priors, double freq)
   {
   for (int i = 0; i < 10; i++)
      priors[i] = 0.0;

   switch (chromosomeType)
      {
      case CT_AUTOSOME :
         priors[geno11] = freq * freq;
         priors[geno12] = 2 * (1. - freq) * freq;
         priors[geno22] = (1. - freq) * (1. - freq);
         break;
      case CT_CHRY :
         priors[geno11] = freq;        /* would be zero for females */
         priors[geno12] = 0.0;
         priors[geno22] = 1. - freq;   /* would be zero for females */
         break;
      case CT_CHRX :
         priors[geno11] = freq;        /* would be freq * freq for females */
         priors[geno12] = 0.;          /* would be 2 * (1. - freq) * freq for females */
         priors[geno22] = 1.  - freq;  /* would be (1. - freq) * (1. - freq) for females */
         break;
      case CT_MITO :
         priors[geno11] = freq;
         priors[geno12] = 0;
         priors[geno22] = 1. - freq;
         break;
      }
   }

void GenotypeLikelihood::GetFemalePriors(double * priors, double freq)
   {
   for (int i = 0; i < 10; i++)
      priors[i] = 0.0;

   switch (chromosomeType)
      {
      case CT_AUTOSOME :
         priors[geno11] = freq * freq;
         priors[geno12] = 2 * (1. - freq) * freq;
         priors[geno22] = (1. - freq) * (1. - freq);
         break;
      case CT_CHRY :
         priors[geno11] = 0.0;            /* would be freq for males */
         priors[geno12] = 0.0;
         priors[geno22] = 0.0;            /* would be 1. - freq for males */
         break;
      case CT_CHRX :
         priors[geno11] = freq * freq;               /* would be freq for males */
         priors[geno12] = 2 * (1. - freq) * freq;    /* would be 0 for males */
         priors[geno22] = (1. - freq) * (1. - freq); /* would be 1. - freq for males */
         break;
      case CT_MITO :
         priors[geno11] = freq;
         priors[geno12] = 0;
         priors[geno22] = 1. - freq;
         break;
      }
   }

double GenotypeLikelihood::OptimizeFrequency()
{
    if ( n < 1000 )
    {
        a = 0.000001; fa = f(a);
        b = 0.4; fb = f(b);
        c = 0.99999; fc = f(c);

        Brent(0.0001);
    }
    else
    {
        a = 0.001/n; fa = f(a);
        b = 0.4; fb = f(b);
        c = 0.99999; fc = f(c);
        
        Brent(0.01/n);
    }

    return min;
}


FilterLikelihood::FilterLikelihood(int count, glfHandler * glfPointers) :
         GenotypeLikelihood(count, glfPointers)
   {
   for (int a1 = 1; a1 <= 4; a1++)
      for (int a2 = a1; a2 <= 4; a2++)
         {
         int index = glfHandler::GenotypeIndex(a1, a2);

         group[index] = a1 == a2 ? 0 : 1;
         }
   }

void FilterLikelihood::SetReferenceAllele(int ref)
   {
   reference = ref;

   for (int a1 = 1; a1 <= 4; a1++)
      for (int a2 = a1; a2 <= 4; a2++)
         {
         int index = glfHandler::GenotypeIndex(a1, a2);

         if (a1 == a2)
            group[index] = a1 == ref ? 0 : 2;
         else
            group[index] = (a1 == ref || a2 == ref) ? 1 : 2;
         }
   }

double FilterLikelihood::Evaluate(double freq)
   {
   double prior11 = freq * freq;
   double prior12 = freq * (1.0 - freq) * 2.0;
   double prior22 = (1.0 - freq) * (1.0 - freq);

   double prior1 = freq;
   double prior2 = 1.0 - freq;

   double likelihood = 0.0;

   double lk[3];
   for (int i = 0; i < n; i++)
      {
      for (int j = 0; j < 3; j++)
         lk[j] = 0.0;

      for (int j = 0; j < 10; j++)
         lk[group[j]] = max(lk[group[j]], glf[i].GetLikelihoods(position)[j]);

      switch (chromosomeType)
         {
         case CT_MITO :
            prior11 = prior1;
            prior12 = 0.0;
            prior22 = prior2;
         case CT_AUTOSOME :
            likelihood += log(prior11 * lk[0] + prior12 * lk[1] +
                              prior22 * lk[2] + 1e-30);
            break;
         case CT_CHRY :
            if (sexes[i] == SEX_MALE)
               likelihood += log(prior1 * lk[0] + prior2 * lk[2] + 1e-30);
            break;
         case CT_CHRX :
            if (sexes[i] == SEX_MALE)
               likelihood += log(prior1 * lk[0] + prior2 * lk[2] + 1e-30);
            else
               likelihood += log(prior11 * lk[0] + prior12 * lk[1] +
                                 prior22 * lk[2] + 1e-30);
         }
      }

   return likelihood;
   }

/*
void PopulationLikelihoods::GetChildPriors(double * priors, int father, int mother, int child, int sex)
   {
   switch (chromosomeType)
      {
      case CT_CHRX :
         if (sex == MALE)
            {
            if (child == 1) return 0.0;
            if (child == 0)
               switch (mother)
                  {
                  case 0 : return 1.0;
                  case 1 : return 0.5;
                  case 2 : return 0.0;
                  }
            if (child == 2)
               switch (mother)
                  {
                  case 0 : return 0.0;
                  case 1 : return 0.5;
                  case 2 : return 1.0
                  }
            }
      case CT_AUTO :
         if (father == 0 && mother == 0 ||
             father == 2 && mother == 2)
             return child == father ? 1.0 : 0.0;
         if (father == 0 && mother == 1 ||
             father == 1 && mother == 0)
             return (child <= 1) ? 0.5 : 0.0;
         if (father == 2 && mother == 1 ||
             mother == 1 && father == 2)
             return (child >= 1) ? 0.5 : 0.0;
         if (mother == 1 && father == 1)
             return (child == 1) ? 0.5 : 0.25;
         if (mother == 2 && father == 0 ||
             mother == 0 && father == 2)
             return child == 1 ? 1.0 : 0.0;
      case CT_CHRY :
         return (sex != MALE) 0.0 ?
                (child == FATHER) ? 1.0 : 0.0;
      case CT_MITO :
         return (child == mother) ? 1.0 - MITO_MUTATION_RATE : MITO_MUTATION_RATE;
      }
   }
*/

