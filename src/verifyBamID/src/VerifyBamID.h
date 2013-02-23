#ifndef __VERIFY_BAM_ID_H
#define __VERIFY_BAM_ID_H

#include <vector>
#include <string>
#include <cmath>
#include "MathGold.h"
#include "BamPileBases.h"
#include "VerifyBamIDArgs.h"

#define MAX_Q 100
#define MAX_DBL 1e99

class GenMatrixBinary {
public:
  //int nInds;
  std::vector<std::string> chroms;
  std::vector<int> positions;
  std::vector<double> alleleFrequencies;
  std::vector<char> refBases;
  std::vector<char> altBases;

  std::vector<std::string> indids;

  std::vector<char> genotypes;
  int bytesPerMarker;

  GenMatrixBinary(const char* vcfFile, bool siteOnly, std::vector<std::string>& subsetInds, double minAF, double minCallRate);
  int addMarker(const char* chrom, int position, char refBase, char altBase, double alleleFreq);
  void setGenotype(unsigned short genotype, int indIndex, int markerIndex = -1);
  int getGenotype(int indIndex, int markerIndex);
  double computeAlleleFrequency(int markerIndex);
};

class VerifyBamOut {
 public:
  VerifyBamOut() {}

  void init(int nRGs, double pRefRef, double pRefHet, double pRefAlt, int maxDepth = -1) {
    llk0s.resize(nRGs+1,0);
    llk1s.resize(nRGs+1,0);

    fMixs.resize(nRGs+1,0);
    refRefs.resize(nRGs+1,pRefRef);
    refHets.resize(nRGs+1,pRefHet);
    refAlts.resize(nRGs+1,pRefAlt);

    numGenos.resize((nRGs+1)*4,0);
    numReads.resize((nRGs+1)*4,0);

    depths.resize((nRGs+1) * (maxDepth+1),0);
  }

  std::vector<double> llk0s;
  std::vector<double> llk1s;
  std::vector<double> fMixs;
  std::vector<double> refRefs;
  std::vector<double> refHets;
  std::vector<double> refAlts;

  std::vector<int> numGenos;
  std::vector<int> numReads;

  std::vector<int> depths;
};

class VerifyBamID {
 public:
  ////////////////////////////////////////////
  // core member variables
  ////////////////////////////////////////////
  BamPileBases* pPile;           // pile of bases at marker sites
  GenMatrixBinary* pGenotypes;   // genotypes containing AFs
  VerifyBamIDArgs* pArgs;        // arguments
  //VerifyBamIDResults vbiResults;

  VerifyBamOut mixOut;
  VerifyBamOut selfOut;
  VerifyBamOut bestOut;

  int nMarkers;     // # SNPs
  int nBases;
  int nRGs;         // # of readGroups

  bool bSameSMFlag;
  bool inferProbRefs;
  double pSN[6]; // pSN[i*3+j] == Pr(Sampled=i|True=j,H0); 0(REF), 1(ALT), 2(others)
  std::vector<std::string> subsetInds;
  double fPhred2Err[MAX_Q+1];

  static double logit(double p) { return log(p/(1.-p)); }
  static double invLogit(double x) { double e = exp(x); return e/(1.+e); }

  ///////////////////////////////////////////
  // core member functions
  //////////////////////////////////////////

 VerifyBamID(VerifyBamIDArgs* p) : pPile(NULL), pGenotypes(NULL), pArgs(p) {
    pSN[0*3+0] = pArgs->pRefRef; 
    pSN[0*3+1] = pArgs->pRefHet;
    pSN[0*3+2] = pArgs->pRefAlt;
    pSN[1*3+0] = 1.-pArgs->pRefRef; 
    pSN[1*3+1] = 1.-pArgs->pRefHet;
    pSN[1*3+2] = 1.-pArgs->pRefAlt;
    
    for(int i=0; i < MAX_Q+1; ++i) {
      // If Phred>=maxQ, assume that the base quality is
      // overestimated and apply an upper threshold.
      if ( i > static_cast<int>(p->maxQ) ) {
	fPhred2Err[i] = fPhred2Err[p->maxQ]; 
      }
      else {
	fPhred2Err[i] = pow(10.,(0-i)/10.);
      }
    }

    /*
    mixLLK0 = mixLLK1 = mlefMix = 0;
    mixRefHet = pArgs->pRefHet;
    mixRefAlt = pArgs->pRefAlt;

    ibdLLK0 = ibdLLK1 = mlefIBD = 0;
    ibdRefHet = pArgs->pRefHet;
    ibdRefAlt = pArgs->pRefAlt;

    numRefBases = numHetBases = numAltBases = 0;
    numRefReads = numHetReads = numAltReads = 0;
    */
    
    nMarkers = nBases = nRGs = 0;
    subsetInds.clear();
  }

  ~VerifyBamID() {
    //if ( pPile != NULL )
      //delete pPile;
      //if ( pGenotypes != NULL )
      //delete pGenotypes;
  }

  void setRefBiasParams(double pRefBaseRefGeno, double pRefBaseHetGeno, double pRefBaseAltGeno) {
    // Pr(ref||RR) = 1
    pSN[0*3+0] = 1;
    // Pr(ref|RA) = pRefBaseHetGeno
    pSN[0*3+1] = pRefBaseHetGeno;
    // Pr(ref|AA) = pRefBaseAltGeno
    pSN[0*3+2] = pRefBaseAltGeno;
    // Pr(alt|RR) = 0
    pSN[1*3+0] = 0;
    // Pr(alt|RA)
    pSN[1*3+1] = 1.-pRefBaseHetGeno;
    // Pr(alt|AA)
    pSN[1*3+2] = 1.-pRefBaseAltGeno;
    //pSN[2*3+0] = pSN[2*3+1] = pSN[2*3+2] = 0;
  }

  void loadSubsetInds(const char* subsetFile);
  void loadFiles(const char* bamFile, const char* vcfFile);

  //double mleMixLLKs(double minMix = 0, double maxMix = 0.5, double tol = 1e-4, int maxIter = 100);
  //double mleIBDLLKs(double minIBD = 0, double maxIBD = 1, double tol = 1e-4, int maxIter = 100);
  //double mleHomLLKs(double minHom = 0, double maxHom = 1, double tol = 1e-4, int maxIter = 100);

  //double computeMixLLKs(double fMix, std::vector<double>& rgLLKs);
  double computeMixLLKs(double fMix, int rgIdx = -1 ); //double* rgLLKs);
  double computeIBDLLKs(double fIBD, int indIdx, int rgIdx = -1 ); //double* rgLLKs, int indIndex);
  void calculateDepthByGenotype(int indIdx, int rg, VerifyBamOut &vbo);
  void calculateDepthDistribution(int maxDepth, VerifyBamOut &vbo);
  void printPerMarkerInfo(const char* outfile, int indIndex);

  class refBiasMixLLKFunc : public VectorFunc {
  public:
    VerifyBamID* pVBI;
    int rgIdx;

    double llk0;
    double llk1;
    double pRefHet;
    double pRefAlt;

  refBiasMixLLKFunc(VerifyBamID* p, int rg) : pVBI(p), rgIdx(rg), llk0(MAX_DBL), llk1(MAX_DBL), pRefHet(0), pRefAlt(0) {
      // calculate null likelihood
      pVBI->setRefBiasParams(1.,0.5,0);
      llk1 = llk0 = (0-pVBI->computeMixLLKs(0, rgIdx));
      pRefHet = 0.5;
      pRefAlt = 0;
  }

    virtual double Evaluate(Vector& v) {
      if ( v.Length() != 2 )
	Logger::gLogger->error("refBiasLLK(): Input vector must be length of 2");

      //double* rgLLKs = new double [(int)pVBI->pPile->vsRGIDs.size()];
      
      double refHet = invLogit(v[0]);
      double refAlt = invLogit(v[1]);

      pVBI->setRefBiasParams(1.,refHet,refAlt);
      double smLLK = 0-pVBI->computeMixLLKs(0, rgIdx); //rgLLKs);

      if ( smLLK < llk1 ) {
	llk1 = smLLK;
	pRefHet = refHet;
	pRefAlt = refAlt;
      }

      return smLLK;
      /*
      if ( rgIdx < 0 ) {
	delete [] rgLLKs;
	return 0-smLLK;
      }
      else {
	double ret = rgLLKs[rgIdx];
	delete [] rgLLKs;
	return 0-ret;
      }
      */
    }
  };

  class fullMixLLKFunc : public VectorFunc {
  public:
    VerifyBamID* pVBI;
    int rgIdx;

    double llk0;
    double llk1;
    double fMix;
    double pRefHet;
    double pRefAlt;

  fullMixLLKFunc(VerifyBamID* p, int rg) : pVBI(p), rgIdx(rg), llk0(MAX_DBL), llk1(MAX_DBL), fMix(0), pRefHet(0), pRefAlt(0) {
      pVBI->setRefBiasParams(1.,0.5,0);
      llk1 = llk0 = (0-pVBI->computeMixLLKs(0, rgIdx));
      pRefHet = 0.5;
      pRefAlt = 0;
    }

    virtual double Evaluate(Vector& v) {
      if ( v.Length() != 3 ) 
	Logger::gLogger->error("fullMixLLKFunc(): Input vector must be length of 3");

      //double* rgLLKs = new double [(int)pVBI->pPile->vsRGIDs.size()];
      
      double mix = invLogit(v[0]);
      double refHet = invLogit(v[1]);
      double refAlt = invLogit(v[2]);

      pVBI->setRefBiasParams(1.,refHet,refAlt);
      double smLLK = 0-pVBI->computeMixLLKs(mix, rgIdx); // rgLLKs);

      if ( smLLK < llk1 ) {
	llk1 = smLLK;
	fMix = mix;
	pRefHet = refHet;
	pRefAlt = refAlt;
      }

      return smLLK;

      /*
      if ( rgIdx < 0 ) {
	delete [] rgLLKs;
	return 0-smLLK;
      }
      else {
	double ret = rgLLKs[rgIdx];
	delete [] rgLLKs;
	return 0-ret;
      }
      */
    }
  };

  class refBiasIbdLLKFunc : public VectorFunc {
  public:
    VerifyBamID* pVBI;
    int rgIdx;
    int indIdx;

    double llk0;
    double llk1;
    double pRefHet;
    double pRefAlt;

  refBiasIbdLLKFunc(VerifyBamID* p, int rg) : pVBI(p), rgIdx(rg), indIdx(0), llk0(MAX_DBL), llk1(MAX_DBL), pRefHet(0), pRefAlt(0) {
      // calculate null likelihood
      pVBI->setRefBiasParams(1.,0.5,0);
      llk1 = llk0 = (0-pVBI->computeIBDLLKs(1., 0, rgIdx));
      pRefHet = 0.5;
      pRefAlt = 0;
  }

    virtual double Evaluate(Vector& v) {
      if ( v.Length() != 2 ) 
	Logger::gLogger->error("refBiasLLK(): Input vector must be length of 2");

      //double* rgLLKs = new double [(int)pVBI->pPile->vsRGIDs.size()];

      double refHet = invLogit(v[0]);
      double refAlt = invLogit(v[1]);

      pVBI->setRefBiasParams(1.,refHet,refAlt);
      double smLLK = 0-pVBI->computeIBDLLKs(1, indIdx, rgIdx); //rgLLKs, indIdx);

      if ( smLLK < llk1 ) {
	llk1 = smLLK;
	pRefHet = refHet;
	pRefAlt = refAlt;
      }
      /*
      if ( rgIdx < 0 ) {
	delete [] rgLLKs;
	return 0-smLLK;
      }
      else {
	double ret = rgLLKs[rgIdx];
	delete [] rgLLKs;
	return 0-ret;
      }
      */
      return smLLK;
    }
  };

  class fullIbdLLKFunc : public VectorFunc {
  public:
    VerifyBamID* pVBI;
    int indIdx;
    int rgIdx;
    double llk0;
    double llk1;
    double fIBD;
    double pRefHet;
    double pRefAlt;
  fullIbdLLKFunc(VerifyBamID* p, int ind, int rg) : pVBI(p), indIdx(ind), rgIdx(rg), llk0(MAX_DBL), llk1(MAX_DBL), fIBD(1), pRefHet(0), pRefAlt(0) {
      pVBI->setRefBiasParams(1.,0.5,0);
      llk1 = llk0 = (0-pVBI->computeIBDLLKs(1, ind, rgIdx));
      pRefHet = 0.5;
      pRefAlt = 0;
    }

    virtual double Evaluate(Vector& v) {
      if ( v.Length() != 3 ) 
	Logger::gLogger->error("fullIbdLLKFunc(): Input vector must be length of 3");

      //double* rgLLKs = new double [(int)pVBI->pPile->vsRGIDs.size()];

      double ibd = invLogit(v[0]);
      double refHet = invLogit(v[1]);
      double refAlt = invLogit(v[2]);

      pVBI->setRefBiasParams(1.,refHet,refAlt);
      double smLLK = 0-pVBI->computeIBDLLKs(ibd, indIdx, rgIdx); // rgLLKs, indIdx);

      if ( smLLK < llk1 ) {
	llk1 = smLLK;
	fIBD = ibd;
	pRefHet = refHet;
	pRefAlt = refAlt;
      }
      /*
      if ( rgIdx < 0 ) {
	delete [] rgLLKs;
	return 0-smLLK;
      }
      else {
	double ret = rgLLKs[rgIdx];
	delete [] rgLLKs;
	return 0-ret;
      }
      */
      return smLLK;
    }
  };

  class ibdLLK : public ScalarMinimizer {
  public:
    VerifyBamID* pVBI;
    int indIdx;
    int rgIdx;
    double llk0;
    double llk1;
    double fIBD;

  ibdLLK(VerifyBamID* p) : pVBI(p), indIdx(0), rgIdx(-1), llk0(0), llk1(0), fIBD(0) {
    }

    virtual double f(double fIBD) {
      //double* rgLLKs = new double [(int)pVBI->pPile->vsRGIDs.size()];
      double smLLK = pVBI->computeIBDLLKs(fIBD, indIdx, rgIdx); //rgLLKs, indIdx);
      return 0-smLLK;
      /*
      if ( rgIdx < 0 ) {
	delete [] rgLLKs;
	return 0-smLLK;
      }
      else {
	double ret = rgLLKs[rgIdx];
	delete [] rgLLKs;
	return 0-ret;
      }
      */
    }

    double OptimizeLLK(int ind = 0, int rg = -1) {
      indIdx = ind;
      rgIdx = rg;

      std::vector<double> lks;
      std::vector<double> alphas;
      double minLK = f(1.);
      lks.push_back(minLK);
      alphas.push_back(0.);
      double grid = pVBI->pArgs->grid;

      int minIdx = 0;
      double alpha;
      for(alpha = grid; alpha < 0.999; alpha += grid) {
	lks.push_back(f(1.-alpha));
	alphas.push_back(alpha);
	if ( lks.back() < minLK ) {
	  minLK = lks.back();
	  minIdx = (int)lks.size()-1;
	}
      }

      if ( minIdx == 0 ) {
	a = 1.; fa = lks[0];
	b = 1.-grid/2.; fb = f(b);
	c = 1.-grid; fc = lks[1];
      }
      else if ( minIdx == (int)lks.size()-1 ) {
	a = 0; fa = f(0);
	b = (1.-alphas.back())/2.; fb = f(b);
	c = 1.-alphas.back(); fc = lks.back();
      }
      else {
	a = 1.-alphas[minIdx-1]; fa = lks[minIdx-1];
	b = 1.-alphas[minIdx]; fb = lks[minIdx];
	c = 1.-alphas[minIdx+1]; fc = lks[minIdx+1];
      }

      Brent(0.0001);

      llk0 = lks[0];
      llk1 = fmin;
      fIBD = min;

      return min;

      /*
      //Logger::gLogger->writeLog("double VerifyBamID::OptimizeLLK() called\n");
      b = 0.95; fb = f(b);
      c = 0; fc = f(c);
      Brent(0.001);
      return min;

      //Logger::gLogger->writeLog("double VerifyBamID::mixLLK::OptimizeLLK( %d ) called",rg);
      rgIdx = rg;
      */
    }
  };

  class mixLLK : public ScalarMinimizer {
  public:
    VerifyBamID* pVBI;
    int rgIdx;
    double llk0;
    double llk1;
    double fMix;

  mixLLK(VerifyBamID* p) : pVBI(p), rgIdx(-1), llk0(0), llk1(0), fMix(0) {}
    virtual double f(double fMix) {
      //Logger::gLogger->writeLog("double VerifyBamID::mixLLK::f() called - rgIdx = %d",rgIdx);
      
      //double* rgLLKs = new double [(int)pVBI->pPile->vsRGIDs.size()];
      double smLLK = pVBI->computeMixLLKs(fMix, rgIdx); // rgLLKs);
      return 0-smLLK;
      /*
      if ( rgIdx < 0 ) {
	delete [] rgLLKs;
	return 0-smLLK;
      }
      else {
	double ret = rgLLKs[rgIdx];
	delete [] rgLLKs;
	return 0-ret;
      }
      */
    }
    
    // mixLLK::OptimizeLLK() 
    double OptimizeLLK(int rg = -1) {
      //Logger::gLogger->writeLog("double VerifyBamID::mixLLK::OptimizeLLK( %d ) called",rg);
      rgIdx = rg;

      std::vector<double> lks;
      std::vector<double> alphas;
      double minLK = f(0);
      lks.push_back(minLK);
      alphas.push_back(0.);
      double grid = pVBI->pArgs->grid;

      int minIdx = 0;
      double alpha;
      for(alpha = grid; alpha < 0.499; alpha += grid) {
	lks.push_back(f(alpha));
	alphas.push_back(alpha);
	if ( lks.back() < minLK ) {
	  minLK = lks.back();
	  minIdx = (int)lks.size()-1;
	}
      }
      if ( minIdx == 0 ) {
	a = 0.; fa = lks[0];
	b = grid/2.; fb = f(b);
	c = grid; fc = lks[1];
      }
      else if ( minIdx == (int)lks.size()-1 ) {
	a = 0.5; fa = f(0.5);
	b = (0.5-alphas.back())/2.; fb = f(b);
	c = alphas.back(); fc = lks.back();
      }
      else {
	a = alphas[minIdx-1]; fa = lks[minIdx-1];
	b = alphas[minIdx]; fb = lks[minIdx];
	c = alphas[minIdx+1]; fc = lks[minIdx+1];
      }

      Brent(0.0001);

      llk0 = lks[0];
      llk1 = fmin;
      fMix = min;

      return min;
    }
  };
};



#endif
