#ifndef __VERIFY_BAM_ID_ARGS_H
#define __VERIFY_BAM_ID_ARGS_H

// command line arguments of verifyBamID
class VerifyBamIDArgs {
public:
  String sSubsetInds;
  String sVcfFile;
  String sBamFile;
  String sOutFile;
  String sSMID;

  bool bSelfOnly;
  bool bSiteOnly;
  bool bFindBest;

  bool bIgnoreRG;
  bool bIgnoreOverlapPair;
  bool bNoEOF;
  bool bPrecise;
  bool bVerbose;
  bool bSilent;

  double genoError;
  double minAF;
  double minCallRate;
  double contamThres;

  double pRefRef;
  double pRefHet;
  double pRefAlt;

  bool bFreeNone;
  bool bFreeMixOnly;
  bool bFreeRefBiasOnly;
  bool bFreeFull;

  bool bChipNone;
  bool bChipMixOnly;
  bool bChipRefBiasOnly;
  bool bChipFull;

  int minMapQ;
  int maxDepth;
  int minQ;
  int maxQ;

  double grid;

  uint16_t includeSamFlag;
  uint16_t excludeSamFlag;

  VerifyBamIDArgs() {
    bSelfOnly = false;
    bSiteOnly = false;
    bFindBest = false;

    bIgnoreRG = false;
    bIgnoreOverlapPair = false;
    bNoEOF = false;
    bPrecise = false;

    genoError = 0.001;
    minAF = 0.01;
    minCallRate = 0.50;
    contamThres = 0.02;

    pRefRef = 1;
    pRefHet = 0.5;
    pRefAlt = 0;

    bFreeNone = false;
    bFreeMixOnly = true;
    bFreeRefBiasOnly = false;
    bFreeFull = false;

    bChipNone = false;
    bChipMixOnly = true;
    bChipRefBiasOnly = false;
    bChipFull = false;

    bVerbose = false;

    minMapQ = 10;
    maxDepth = 20;
    minQ = 13;
    maxQ = 40;

    grid = 0.05;

    includeSamFlag = 0x0000;
    excludeSamFlag = 0x0704;
  }
};

#endif // __VERIFY_BAM_ID_ARGS_H
