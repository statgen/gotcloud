#ifndef __VARIANT_STATIZER_H
#define __VATIANT_STATIZER_H

#define MAX_READS_PER_BASE 10000

#include <stdint.h>
#include <vector>
#include <cmath>
#include <utility>
//#include <boost/thread/mutex.hpp>
#include "libVcfVcfFile.h"


// vCounts contains the following information
// 1. # OBSERVED A-FWD
// 2. # OBSERVED A-REV
// 3. # OBSERVED C-FWD
// 4. # OBSERVED C-REV
// 5. # OBSERVED G-FWD
// 6. # OBSERVED G-REV
// 7. # OBSERVED T-FWD
// 8. # OBSERVED T-REV
// 9. # OBSERVED N-FWD
// 10. # OBSERVED N-REV
// 11. # OBSERVED D-FWD
// 12. # OBSERVED D-REV

// vQualCounts contains the following information
// 1. # WEIGHTED A-FWD
// 2. # WEIGHTED A-REV
// 3. # WEIGHTED C-FWD
// 4. # WEIGHTED C-REV
// 5. # WEIGHTED G-FWD
// 6. # WEIGHTED G-REV
// 7. # WEIGHTED T-FWD
// 8. # WEIGHTED T-REV
// 9. # WEIGHTED N-FWD
// 10. # WEIGHTED N-REV
// 11. # WEIGHTED D-FWD
// 12. # WEIGHTED D-REV

// vCycleCounts contains the following information

// statistics to calculate
// SBR : Strand bias as correlation between (% fwd strand, % alt base)
// SBZ : Strand bias as z-score between (% fwd strand, % alt base)
// CBR : Cycle bias as correlation between (# cycle, % alt base)
// CBZ : Cycle bias as z-score between (# cycle, % alt base)
// TBR : Tail bias as correlation between (signed # cycle, % alt base)
// TBZ : Tail bias as z-score between (signed # cycle, % alt base)
// XNR : Excessive fraction of non-reference bases than expected
// LRS : Likelihood-ratio between H1:Pr(SNP|AF,correct errors), H2:Pr(noSNP|adjusted errors)

class VariantStatizer {
 private:
  // list of input VCF and output VCFs
  libVcf::VcfFile anchorVcf;
  libVcf::VcfMarker* pCurrentMarker;
  //String sAnchorVcf;
  std::vector<libVcf::VcfFile*> pPileVcfs;
  IFILE outFile;

  // For now, assume that the all VCFs are coming from the same VCF
  String sChrom;
  
  std::vector<uint8_t> vBase2Num;
  std::vector<double> vPhred2Err;
  std::vector<double> vPhred2Match;
  std::vector<double> vPhred2Het;
  std::vector<double> p2e;

  int anchorPos;
  int anchorAl1;
  int anchorAl2;
  double anchorAF;
  double emAF;

  // list of latest position, INT_MAX when ended
  // list of Allele1, Allele2, Allele Frequencies
  // String sAnchorVcf;
  // std::vector<int> vPos;
  //std::vector<int> vAl1;
  // std::vector<int> vAl2;

  std::vector<int>     nReads;
  std::vector<uint8_t*>   pcBases;
  std::vector<uint8_t*>   pcMapQs;
  std::vector<uint8_t*>   pcQuals;
  std::vector<uint8_t*>   pcStrands;
  std::vector<uint16_t*>  pcCycles;
  std::vector<uint16_t*>  pcHashes;
  std::vector<int>     nPLs;

  void writeCurrentMarker(IFILE oFile);
  bool advancePileVcf(int index);
  bool readMarker(int index, libVcf::VcfMarker* pMarker);

 public:
 VariantStatizer() : pCurrentMarker(NULL) {
    for(int i=0; i < 256; ++i) {
      switch((char)i) {
      case 'A': case 'a':
	vBase2Num.push_back((uint8_t)1);
	break;
      case 'C': case 'c':
	vBase2Num.push_back((uint8_t)2);
	break;
      case 'G': case 'g':
	vBase2Num.push_back((uint8_t)3);
	break;
      case 'T': case 't':
	vBase2Num.push_back((uint8_t)4);
	break;
      case 'N': case 'n':
	vBase2Num.push_back((uint8_t)5);
	break;
      case 'D': case 'd':
	vBase2Num.push_back((uint8_t)6);
	break;
      default:
	vBase2Num.push_back(0);
      }
    }

    for(int i=0; i < 256; ++i) {
      double e = pow(0.1,i/10.);
      vPhred2Err.push_back(e);
      vPhred2Match.push_back(log10(1.-e));
      vPhred2Het.push_back(log10(0.5-e/3.));
    }
  }

  bool loadAnchorVcf(const char* file);
  bool appendStatVcf(const char* file);
  bool writeMergedVcf(const char* outFile);
  std::pair<double,double> estimateAF(double eps);
  //bool openOutputFile(const char* file);
  //#bool advanceMarker();
  //bool closeOutputFile(const char* file);
  static double cor22(int a, int b, int c, int d);
  static double qcor(double sumA, double sumSqA, double sumB, double sumSqB, double sumAB, int n);
};

#endif


