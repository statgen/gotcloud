#include "GlfLikelihoods.h"
#include "Error.h"

#define MAX_EM_ITER 100
#define TOL_EM 1e-6

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


FullLikelihood::FullLikelihood(int count, glfHandler * glfPointers) :
         GenotypeLikelihood(count, glfPointers) {
  dGPs = new double[count * 10];
  GPs = new double[count * 10];
  APs = new double[count * 5];
  sumPs = new double[count];
  dsumPs = new double[count];
  bestGenotypes = new int[count];
  qualGenotypes = new int[count];
  ploidies = new unsigned char[count];
}

FullLikelihood::~FullLikelihood() {
  if ( dGPs != NULL ) delete [] dGPs;
  if ( GPs != NULL ) delete [] GPs;
  if ( APs != NULL ) delete [] APs;
  if ( sumPs != NULL ) delete [] sumPs;
  if ( dsumPs != NULL ) delete [] dsumPs;
  if ( bestGenotypes != NULL ) delete [] bestGenotypes;
  if ( qualGenotypes != NULL ) delete [] qualGenotypes;
}

void FullLikelihood::SetAlleles(int _ref, int* _alts) {
  ref = _ref;
  alts[0] = _alts[0];
  alts[1] = _alts[1];
  alts[2] = _alts[2];
}

double FullLikelihood::OptimizeFrequency(int priorAN, int* priorACs) {
  double pACs[3] = {0,0,0};
  if ( priorACs != NULL ) {
    pACs[0] = priorACs[0];
    pACs[1] = priorACs[1];
    pACs[2] = priorACs[2];
  }
  // assume biallelic markers with HWE
  // start with an arbitrary allala frequency and run EM algorithm
  freqs[0] = freqs[1] = freqs[2] = freqs[3] = freqs[4] = 0;
  if ( alts[0] == 0 ) {
    error("OpimitzeFrequency() called on monomorphic marker");
  }
  else if ( alts[1] == 0 ) {
    freqs[ref] = (0.6*n*2 + priorAN - pACs[0])/(2*n + priorAN);
    freqs[alts[0]] = (0.4*n*2 + pACs[0])/(2*n + priorAN);
  }
  else if ( alts[2] == 0 ) {
    freqs[ref] = (0.4*n*2 + priorAN - pACs[0] - pACs[1])/(2*n + priorAN);
    freqs[alts[0]] = (0.3*n*2 + pACs[0] )/(2*n + priorAN);
    freqs[alts[1]] = (0.3*n*2 + pACs[1] )/(2*n + priorAN);
  }
  else {
    freqs[ref] = (0.25 * n * 2 + priorAN - pACs[0] - pACs[1] - pACs[2]) / (2*n + priorAN);
    freqs[alts[0]] = (0.25*n*2 + pACs[0] )/(2*n + priorAN);
    freqs[alts[1]] = (0.25*n*2 + pACs[1] )/(2*n + priorAN);
    freqs[alts[2]] = (0.25*n*2 + pACs[1] )/(2*n + priorAN);
  }

  double priorsD[10];
  double* isums;
  double fsums[5];
  double dsums[10];
  const double* lks;
  int i, j, k, l, r, lindex, an, dn;

  bool hweGo = true;
  bool hwdGo = true;

  memset(GPs, 0, sizeof(double)*10*n);
  memset(dGPs, 0, sizeof(double)*10*n);

  for(r=0; r < MAX_EM_ITER; ++r) {
    for(i=0, k=0; i < 4; ++i) {
      for(j=i; j < 4; ++j, ++k) {
	priorsD[k] = freqs[i+1] * freqs[j+1] * (i == j ? 1 : 2);
	if ( r == 0 )
	  dfreqs[k] = priorsD[k];
      }
    }

    fsums[0] = fsums[1] = fsums[2] = fsums[3] = fsums[4] = 0;

    memset(dsums, 0, sizeof(double)*10);
    an = dn = 0;
    if ( priorAN > 0 ) {
      fsums[ref] = (double)(priorAN - pACs[0] - pACs[1] - pACs[2]);
      fsums[alts[0]] = (double)pACs[0];
      if ( alts[1] > 0 )
	fsums[alts[1]] = (double)pACs[1];
      if ( alts[2] > 0 )
	fsums[alts[2]] = (double)pACs[2];

      for(i=0, k=0; i < 4; ++i) {
	for(j=i; j < 4; ++j, ++k) {
	  dsums[k] = fsums[i+1] * fsums[j+1] / priorAN / 2.0 * (i == j ? 1 : 2);
	}
      }
      an = priorAN;
      dn = priorAN/2;
    }
    
    if ( chromosomeType == CT_AUTOSOME ) {
      for(i=0; i < n; ++i) {
	isums = APs + (5*i);
	isums[0] = isums[1] = isums[2] = isums[3] = isums[4] = 0;
	dsumPs[i] = 0;
	lks = glf[i].GetLikelihoods(position);
	for(j=0, l=0; j < 4; ++j) {
	  for(k=j; k < 4; ++k, ++l) {
	    if ( priorsD[l] > 0 ) {
	      GPs[10*i+l] = priorsD[l] * lks[l];
	      isums[j+1] += GPs[10*i+l];
	      isums[k+1] += GPs[10*i+l];
	      dsumPs[i] += ( dGPs[10*i+l] = dfreqs[l] * lks[l]);
	    }
	  }
	}
	sumPs[i] = isums[0] = isums[1] + isums[2] + isums[3] + isums[4];

	for(j=1; j <= 4; ++j) 
	  fsums[j] += isums[j]/isums[0]*2.0;

	for(j=0; j < 10; ++j) 
	  dsums[j] += dGPs[10*i+j]/dsumPs[i];
	
	an += 2;
	++dn;

	ploidies[i] = 2;
      }
    }
    else if ( chromosomeType == CT_CHRX ) {
      for(i=0; i < n; ++i) {
	isums = APs + (5*i);
	isums[0] = isums[1] = isums[2] = isums[3] = isums[4] = 0;
	dsumPs[i] = 0;
	lks = glf[i].GetLikelihoods(position);
	if (sexes[i] == SEX_MALE) {
	  for(j=0, l=0; j < 4; ++j) {
	    isums[j+1] += (GPs[10*i+l] = freqs[j+1] * lks[l]);
	    l += (4-j);
	  }
	  sumPs[i] = isums[0] = isums[1] + isums[2] + isums[3] + isums[4];	  
	  for(j=1; j <= 4; ++j) 
	    fsums[j] += isums[j]/isums[0];
	  ++an;
	  ploidies[i] = 1;
	}
	else {
	  for(j=0, l=0; j < 4; ++j) {
	    for(k=j; k < 4; ++k, ++l) {
	      if ( priorsD[l] > 0 ) {
		GPs[10*i+l] = priorsD[l] * lks[k];
		isums[j+1] += GPs[10*i+l];
		isums[k+1] += GPs[10*i+l];
		dsumPs[i] += ( dGPs[10*i+l] = dfreqs[l] * lks[l]);
	      }
	    }
	  }
	  sumPs[i] = isums[0] = isums[1] + isums[2] + isums[3] + isums[4];

	  for(j=1; j <= 4; ++j) 
	    fsums[j] += isums[j]/isums[0] * 2.0;

	  for(j=0; j < 10; ++j) 
	    dsums[j] += dGPs[10*i+j]/dsumPs[i];
	  
	  an += 2;
	  ++dn;
	  ploidies[i] = 2;
	}
      }
    }
    else if ( chromosomeType == CT_CHRY ) {
      for(i=0; i < n; ++i) {
	isums = APs + (5*i);
	isums[0] = isums[1] = isums[2] = isums[3] = isums[4] = 0;
	lks = glf[i].GetLikelihoods(position);
	if (sexes[i] == SEX_MALE) {
	  for(j=0, l=0; j < 4; ++j) {
	    isums[j+1] += (GPs[10*i+l] = freqs[j+1] * lks[l]);
	    l += (4-j);
	  }
	  sumPs[i] = isums[0] = isums[1] + isums[2] + isums[3] + isums[4];	  
	  for(j=1; j <= 4; ++j) 
	    fsums[j] += isums[j]/isums[0];
	  ++an;
	  ploidies[i] = 1;
	}
	else {
	  for(j=0, l=0; j < 4; ++j) {
	    for(k=j; k < 4; ++k, ++l) {
	      GPs[10*i+l] = 0;
	    }
	  }
	  sumPs[i] = 0;
	  ploidies[i] = 0;
	}
      }
    }
    else if ( chromosomeType == CT_MITO ) {
      for(i=0; i < n; ++i) {
	isums = APs + (5*i);
	isums[0] = isums[1] = isums[2] = isums[3] = isums[4] = 0;
	lks = glf[i].GetLikelihoods(position);
	for(j=0, l=0; j < 4; ++j) {
	  isums[j+1] += (GPs[10*i+l] = freqs[j+1] * lks[l]);
	    l += (4-j);
	}
	sumPs[i] = isums[0] = isums[1] + isums[2] + isums[3] + isums[4];	  
	for(j=1; j <= 4; ++j) 
	  fsums[j] += isums[j]/isums[0];
	++an;
	ploidies[i] = 1;
      }
    }
    else {
      error("Invalid chromsomeType %d", chromosomeType);
    }

    //fprintf(stderr,"%d r=%d\n",position,r);
    
    for(j=1; j <= 4; ++j) 
      fsums[j] /= an;

    if ( dn > 0 ) {
      for(j=0; j < 10; ++j) 
	dsums[j] /= dn;
    }

    double diff = 0;
    for(j=1; j <= 4; ++j) 
      diff += fabs(freqs[j]-fsums[j]);

    if ( diff < TOL_EM )
      hweGo = false;

    diff = 0;

    for(j=0; j < 10; ++j) 
      diff += fabs(dfreqs[j]-dsums[j]);

    if ( diff < TOL_EM * 10 )
      hwdGo = false;

    if ( fabs(freqs[1]-fsums[1]) + fabs(freqs[2]-fsums[2]) + fabs(freqs[3]-fsums[3]) + fabs(freqs[4]-fsums[4]) < TOL_EM ) 
      hweGo = false;

    
    for(j=1; j <= 4; ++j) 
      freqs[j] = fsums[j];

    for(j=0; j < 10; ++j) 
      dfreqs[j] = dsums[j];

    if ( !hweGo && !hwdGo ) break;
  }

  // calculate likelihood and return
  double llk = 0.0;
  hwdLLK = 0.0;
  for(i=0; i < n; ++i) {
    if ( ploidies[i] > 0 )
      llk += log(sumPs[i]/ploidies[i] + 1e-30);
    if ( ploidies[i] == 2 )
      hwdLLK += log(dsumPs[i] + 1e-30);
  }

  min = 0-llk;

  //fprintf(stderr,"%d %d %d %d %.6lf %.6lf %.6lf %.6lf %.6lf\n",ref, alts[0], alts[1], alts[3], freqs[0],freqs[1],freqs[2],freqs[3],freqs[4]);

  for(i=0; i < n; ++i) {
    bestGenotypes[i] = 0;
    for(j=1; j < 10; ++j) {
      if ( GPs[10*i + bestGenotypes[i]] < GPs[10*i + j] )
	bestGenotypes[i] = j;
    }
    if ( ploidies[i] > 0 )
      qualGenotypes[i] = (int)(-10 * log(1.0 - GPs[10*i + bestGenotypes[i]] * ploidies[i]/ sumPs[i])/log(10.) + 0.5);
  }

  return min;
}

double FullLikelihood::inbreedingCoeff() {
  double sumHets = 0;
  int sumPlds = 0;
  int gIdx = glfHandler::GenotypeIndex(ref, alts[0]);
  for(int i=0; i < n; ++i) {
    if ( ploidies[i] == 2 ) {
      sumHets += dGPs[10*i + gIdx]/dsumPs[i];
      sumPlds += 2;
    }
  }
  if ( sumHets < 0.5 ) // the marker is monomorphic
    return 0.0;
  else 
    return 1.0 - sumHets/( freqs[ref] * (1.0-freqs[ref]) * sumPlds + 1e-30);
}

double FullLikelihood::hwdLRT() {
  return ( 2.0 * ( hwdLLK + min > 0 ? hwdLLK + min : 0 ) );
}



