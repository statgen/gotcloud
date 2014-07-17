#ifndef __GLFLIKELIHOODS_H__
#define __GLFLIKELIHOODS_H__

#include "glfHandler.h"
#include "MathGold.h"
#include "Pedigree.h"

#include <math.h>

// Chromosome types
#define CT_AUTOSOME     0
#define CT_CHRX         1
#define CT_CHRY         2
#define CT_MITO         3

class GenotypeLikelihood : public ScalarMinimizer
   {
   public:
      int        n;
      glfHandler * glf;
      char       * sexes;
      int        chromosomeType;
      int        position;

      GenotypeLikelihood(int count, glfHandler * glfPointers);
      virtual ~GenotypeLikelihood();

      void SetAlleles(int al1, int al2);

      virtual double f(double freq) { return -Evaluate(freq); }

      virtual double Evaluate(double freq);

      void GetPriors(double * priors, double freq, int i);
      void GetMalePriors(double * priors, double freq);
      void GetFemalePriors(double * priors, double freq);

      double OptimizeFrequency();

   protected:
      int allele1, allele2;
      int geno11, geno12, geno22;
   };

class FilterLikelihood : public GenotypeLikelihood
   {
   public:
      FilterLikelihood(int count, glfHandler * glfPointers);

      void SetReferenceAllele(int ref);

      virtual double Evaluate(double freq);

   protected:
      int reference;
      int group[10];
   };

class FullLikelihood : public GenotypeLikelihood {
 public:
  FullLikelihood(int count, glfHandler * glfPointers);
  virtual ~FullLikelihood();

  void SetAlleles(int _ref, int* _alts);

  double OptimizeFrequency(int priorAN = 0, int* priorACs = NULL);
  double inbreedingCoeff();
  double hwdLRT();

  double* dGPs;
  double* GPs;
  double* APs;
  double* sumPs;
  double* dsumPs;
  int ref;
  int alts[3];
  double freqs[5];
  double dfreqs[10];
  int* bestGenotypes;
  int* qualGenotypes;
  unsigned char* ploidies;
  double hwdLLK;
};


#endif

