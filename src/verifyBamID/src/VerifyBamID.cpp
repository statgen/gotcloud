#include "VerifyBamID.h"
#include "StringArray.h"
#include "InputFile.h"
#include "VcfFile.h"
#include "BgzfFileType.h"

GenMatrixBinary::GenMatrixBinary(const char* vcfFile, bool siteOnly, std::vector<std::string>& subsetInds, double minAF, double minCallRate) {
  // open a VCF file
  VcfFile vcf;
  VcfMarker* pMarker;
  std::vector<int> indIndices;

  vcf.bSiteOnly = siteOnly;
  if ( !siteOnly ) {
    vcf.bParseGenotypes = true;
    vcf.bParseDosages = false;
    vcf.bParseValues = false;
  }
  vcf.openForRead(vcfFile);

  // match the individual IDs;
  if ( siteOnly ) {
    if ( subsetInds.size() > 0 ) {
      Logger::gLogger->warning("--siteOnly option is turned on with subset of individuals information provided. subset information will be ignored");
    }
  }
  else {
    if ( subsetInds.size() == 0 ) {
      for(int i=0; i < (int)vcf.vpVcfInds.size(); ++i) {
	indids.push_back(vcf.vpVcfInds[i]->sIndID.c_str());
	indIndices.push_back(i);
      }
    }
    else {
      for(int i=0; i < (int)vcf.vpVcfInds.size(); ++i) {
	for(int j=0; j < (int)subsetInds.size(); ++j) {
	  if ( vcf.vpVcfInds[i]->sIndID.Compare( subsetInds[j].c_str() ) == 0 ) {
	    indids.push_back(vcf.vpVcfInds[i]->sIndID.c_str());
	    indIndices.push_back(i);
	    break;
	  }
	}
      }
      Logger::gLogger->writeLog("Total of %d out of %d individuals successfully matched IDs",(int)indids.size(),(int)subsetInds.size());
    }
  }

  // set bytesPerMarker attribute
  if ( siteOnly ) {
    bytesPerMarker = 0;
  }
  else {
    bytesPerMarker = (indids.size() + 3)/4;
  }

  // read each marker and stores genotype
  while( vcf.iterateMarker() ) {
    // set per-marker level information
    if ( vcf.nNumMarkers % 10000 == 0 ) {
      Logger::gLogger->writeLog("Reading %d markers from VCF file",vcf.nNumMarkers);
    }

    pMarker = vcf.getLastMarker();

    // get allele frequency information from VCF file
    // if site-only is set
    //    -- use INFO
    // else if subset is set
    //    -- use subset genotypes
    // else 
    //    -- use INFO if available
    //    -- otherwise, use all genotypes
    double AF = -1;
    double callRate = 1.;
    // if site-only is set use INFO only
    if ( siteOnly ) { 
      // use AC and AN first to estimate AF
      const char* sAC = pMarker->getInfoValue("AC");
      const char* sAN = pMarker->getInfoValue("AN");
      int AC = (sAC == NULL) ? -1 : atoi(sAC);
      int AN = (sAN == NULL) ? -1 : atoi(sAN);

      if ( ( AC > 0 ) && ( AN > 0 ) ) {
	AF = (double)AC/(double)AN;
	if ( vcf.vpVcfInds.size() > 0 ) {
	  callRate = AN / 2. / vcf.vpVcfInds.size();
	}
      }
      if ( AF < 0 ) {
	const char* sAF = pMarker->getInfoValue("AF");
	AF = (sAF == NULL) ? -1. : atof(sAF);
      }
    }
    // if subset is set, do not use INFO and use genotypes
    else if ( indIndices.size() > 1 ) { // if not self-only option
      std::pair<int,int> alleleCounts = pMarker->computeAlleleCounts(indIndices);
      AF = (double)alleleCounts.first/(double)(alleleCounts.second+1e-6);
      callRate = (double)alleleCounts.second / 2. / subsetInds.size();
    }
    // if selfOnly or use-all, use INFO first and genotypes later
    else if ( vcf.vpVcfInds.size() >= 0 ) {
      // use AC and AN first to estimate AF
      const char* sAC = pMarker->getInfoValue("AC");
      const char* sAN = pMarker->getInfoValue("AN");
      int AC = (sAC == NULL) ? -1 : atoi(sAC);
      int AN = (sAN == NULL) ? -1 : atoi(sAN);

      if ( ( AC > 0 ) && ( AN > 0 ) ) {
	AF = (double)AC/(double)AN;
	if ( vcf.vpVcfInds.size() > 0 ) {
	  callRate = AN / 2. / vcf.vpVcfInds.size();
	}
      }
      if ( AF < 0 ) {
	const char* sAF = pMarker->getInfoValue("AF");
	AF = (sAF == NULL) ? -1. : atof(sAF);
      }
      // use all genotype if INFO field does not have AF, AC, AN
      if ( AF < 0 ) {
	std::pair<int,int> alleleCounts = pMarker->computeAlleleCounts();
	AF = (double)alleleCounts.first/(double)(alleleCounts.second+1e-6);
	callRate = (double)alleleCounts.second / 2. / vcf.vpVcfInds.size();
      }
    }

    if ( AF < 0 ) {
      Logger::gLogger->warning("Cannot obtain allele frequency information at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
    }

    // skip by AF or callRate 
    if ( AF < minAF ) 
      continue;
    if ( callRate < minCallRate ) 
      continue;

    // skip non-bi-allelic marker
    if ( pMarker->asAlts.Length() > 1 ) {
      Logger::gLogger->warning("Skipping marker %s:%d with multiple alternative alleles",pMarker->sChrom.c_str(),pMarker->nPos);
      continue;
    }

    // add marker information
    addMarker(pMarker->sChrom.c_str(), pMarker->nPos, pMarker->sRef[0], pMarker->asAlts[0][0], AF);

    // set genotypes
    if ( siteOnly ) {
      // no genotypes can be stored, skip them
    }
    else {
      for(int i=0; i < (int)indIndices.size(); ++i) {
	setGenotype( pMarker->vnSampleGenotypes[indIndices[i]], i );
      }
    }
  }

  Logger::gLogger->writeLog("Finished reading %d markers from VCF file",vcf.nNumMarkers);
  Logger::gLogger->writeLog("Total of %d informative markers passed after AF >= %lf and callRate >= %lf threshold",(int)chroms.size(),minAF,minCallRate);

  if ( chroms.size() == 0 ) {
    Logger::gLogger->error("No informative markers were found. Does the VCF have individual genotypes or either AF entry or AC & AN entries included in the INFO field?");
  }
}

int GenMatrixBinary::addMarker(const char* chrom, int position, char refBase, char altBase, double alleleFreq) {
  chroms.push_back(chrom);
  positions.push_back(position);
  refBases.push_back(refBase);
  altBases.push_back(altBase);
  alleleFrequencies.push_back(alleleFreq);

  for(int i=0; i < bytesPerMarker; ++i) {
    genotypes.push_back(0);
  }

  return (int)chroms.size();
}

int GenMatrixBinary::getGenotype(int indIndex, int markerIndex) {
  int genoIndex = markerIndex * bytesPerMarker + indIndex / 4;
  int offset = (indIndex % 4) * 2;
  return static_cast<int>(( genotypes[genoIndex] >> offset ) & 0x03);
}

double GenMatrixBinary::computeAlleleFrequency(int markerIndex) {
  int genoIndex = (chroms.size()-1) * bytesPerMarker;
  int AC = 0;
  int AN = 0;
  for(int i=0; i < bytesPerMarker; ++i) {
    for(int j=0; j < 8; j += 2) {
      switch ( (genotypes[genoIndex + i] >> j) & 0x03 ) {
      case 0: // MISSING
	break;
      case 1: // HOMREF
	AN += 2;
	break;
      case 2: // HET
	AN += 2;
	AC += 1;
	break;
      case 3:
	AN += 2;
	AC += 2;
	break;
      default:
	Logger::gLogger->error("Invalid genotype at marker index %d",markerIndex);
      }
    }
  }
  return ( (AN > 0) ? (double)AC/(double)AN : -1. );
}

void GenMatrixBinary::setGenotype(unsigned short genotype, int indIndex, int markerIndex) {
  int genoIndex = (chroms.size()-1) * bytesPerMarker + (indIndex / 4);
  //int shift = ((indIndex % bytesPerMarker) * 2);
  int shift = ((indIndex % 4) * 2);
  int g1 = (genotype & 0x007f);
  int g2 = ((genotype & 0x7f00) >> 8);
  if ( g1 == 0x007f ) { // missing genotype - 0
    genotypes[genoIndex] |= (0x0 << shift);
  }
  else if ( g1 + g2 == 0 ) {
    genotypes[genoIndex] |= (0x1 << shift);
  }
  else if ( g1 + g2 == 1 ) {
    genotypes[genoIndex] |= (0x2 << shift);
  }
  else if ( g1 + g2 == 2 ) {
    genotypes[genoIndex] |= (0x3 << shift);
  }
  else {
    Logger::gLogger->error("Invalid genotype %d/%d at marker %s:%d",g1,g2,chroms.back().c_str(),positions.back());
  }
}

void VerifyBamID::loadSubsetInds(const char* subsetFile) {
  if ( ( pPile == NULL ) && ( pGenotypes == NULL ) ) {
    if ( subsetInds.size() > 0 ) {
      Logger::gLogger->error("VerifyBamID::loadSubsetInds() called multiple times");
    }

    IFILE f = ifopen(subsetFile,"rb");
    String line;
    StringArray tok;
    while( line.ReadLine(f) > 0 ) {
      tok.ReplaceTokens(line,"\t \n\r");
      subsetInds.push_back(tok[0].c_str());
    }
  }
  else {
    Logger::gLogger->error("VerifyBamID::loadSubsetInds() called after VerifyBamID::loadFiles()");
  }
}

void VerifyBamID::loadFiles(const char* bamFile, const char* vcfFile) {
  // create a pile object
  Logger::gLogger->writeLog("Opening BAM file %s",bamFile);

  const char* smID = pArgs->sSMID.IsEmpty() ? NULL : pArgs->sSMID.c_str();

  pPile = new BamPileBases(bamFile, smID, pArgs->bIgnoreRG);
  pPile->minMapQ = pArgs->minMapQ;
  pPile->maxDepth = pArgs->maxDepth;
  pPile->minQ = pArgs->minQ;
  pPile->maxQ = pArgs->maxQ;
  pPile->includeSamFlag = pArgs->includeSamFlag;
  pPile->excludeSamFlag = pArgs->excludeSamFlag;
  //pPile->bIgnoreRG = pArgs->bIgnoreRG;

  if ( pArgs->bNoEOF ) {
    BgzfFileType::setRequireEofBlock(false);
  }

  // set # of readGroups when loading BAMs
  nRGs = (int)pPile->vsRGIDs.size();
  mixOut.init(nRGs,pArgs->pRefRef,pArgs->pRefHet,pArgs->pRefAlt,pArgs->maxDepth);
  selfOut.init(nRGs,pArgs->pRefRef,pArgs->pRefHet,pArgs->pRefAlt,0);
  bestOut.init(nRGs,pArgs->pRefRef,pArgs->pRefHet,pArgs->pRefAlt,0);

  // set up individuals to subset
  if ( pArgs->bSiteOnly ) {
    if ( subsetInds.size() > 0 ) {
      Logger::gLogger->error("--siteOnly option cannot be combined with --subset option");
    }
  }
  else if ( pArgs->bSelfOnly )  {
    Logger::gLogger->writeLog("--selfOnly option applied : finding sample ID %s from VCF file", pPile->sBamSMID.c_str());
    if ( ! (pArgs->sSubsetInds.IsEmpty()) ) {
      Logger::gLogger->error("--selfOnly option cannot be combined with --subset option");
    }
    if ( ! pPile->bSameSMFlag ) 
      Logger::gLogger->error("The BAM file contains multiple individuals, so cannot use --selfOnly option");
    subsetInds.push_back(pPile->sBamSMID);
    //fprintf(stderr,"bar\n");
  }

  Logger::gLogger->writeLog("Opening VCF file %s",vcfFile);
  // create genotype matrix, and load vcfFile
  pGenotypes = new GenMatrixBinary(vcfFile, pArgs->bSiteOnly, subsetInds, pArgs->minAF, pArgs->minCallRate);

  Logger::gLogger->writeLog("Reading BAM file %s",bamFile);
  // read base information corresponding to each marker
  nMarkers = (int)pGenotypes->chroms.size();
  
  for(int i=0; i < nMarkers; ++i) {
    if ( ( i > 0 ) && ( i % 10000 == 0 ) ) {
      Logger::gLogger->writeLog("Extracting read information in %d markers from BAM file",i);
    }
    //int nb = 
    pPile->readMarker(pGenotypes->chroms[i].c_str(), pGenotypes->positions[i], pArgs->bIgnoreOverlapPair);
    //++markerDPs[nb];
  }
  nBases = pPile->cBases.size();
  Logger::gLogger->writeLog("Finished extracting %d bases in %d markers from BAM file -- Avg Depth = %.3lf", nBases, nMarkers, (double)nBases/nMarkers);
  Logger::gLogger->writeLog("Finished Reading BAM file %s and VCF file %s\n",bamFile,vcfFile);
}

// computeMixLLKs() - calculate Pr(Data|fMix) for each SM and RG
//                    given AF and 
double VerifyBamID::computeMixLLKs(double fMix, int rgIdx) { //{ double* rgLLKs) {
//int nMarkers = (int)(pGenotypes->chroms.size());
//int nRGs = (int)(pPile->vsRGIDs.size());
  double genoFreq[3], baseLKs[9], smMarkerLKs[9];
  double af, baseError, baseMatch;
  char a1, a2, base;
  double smLLK = 0;
  double tmpf;
//  double* rgMarkerLKs = new double[nRGs*9];
//memset(rgLLKs, 0, sizeof(double)*nRGs);

  //fprintf(stderr,"nRGs=%d\n",nRGs);

  for(int i=0; i < nMarkers; ++i) {
    af = pGenotypes->alleleFrequencies[i];
    // force allele-frequency as nonzero to avoid boundary conditions
    if ( af < 0.001 ) af = 0.001;
    if ( af > 0.999 ) af = 0.999;

    // frequency of genotypes under HWE
    genoFreq[0] = (1.-af)*(1.-af);
    genoFreq[1] = 2.*af*(1.-af);
    genoFreq[2] = af*af;
    a1 = pGenotypes->refBases[i];
    a2 = pGenotypes->altBases[i];

    // initialize the marker-level likelihoods
    for(int k=0; k < 9; ++k) {
      smMarkerLKs[k] = (pArgs->bPrecise ? 0. : 1.);
    }
    /*
    for(int k=0; k < 9 * nRGs; ++k) {
      rgMarkerLKs[k] = (pArgs->bPrecise ? 0. : 1.);
    }
    */

    for(int j=(int)pPile->nBegins[i]; j < (int)pPile->nEnds[i]; ++j) {
      // obtain b (base), (error), and readgroup info
      if ( ( rgIdx >= 0 ) && ( rgIdx != (int)pPile->nRGIndices[j] ) ) continue;

      base = pPile->cBases[j];
      baseError = fPhred2Err[pPile->cQuals[j]-33];
      baseMatch = 1.-baseError;

      //rgIdx = static_cast<int>(pPile->nRGIndices[j]);

      for(int k1=0; k1 < 3; ++k1) {
	  for(int k2=0; k2 < 3; ++k2) {
	    baseLKs[k1*3+k2] = ( fMix * pSN[0*3+k1] + (1.-fMix) * pSN[0*3+k2] ) * ( base == a1 ? baseMatch : baseError/3.) + ( fMix * pSN[1*3+k1] + (1.-fMix) * pSN[1*3+k2] ) * ( base == a2 ? baseMatch : baseError/3. );
	  }
      }

      // merge base-level likelihood into marker-level likelihood
      // smMarkerLKs[i*3+j] 
      //   = \prod Pr(b|G1,G2) = \prod (f Pr(b|G1) + (1-f) Pr(b|G2))
      for(int k1=0; k1 < 3; ++k1) {
	for(int k2=0; k2 < 3; ++k2) {
	  if ( pArgs->bPrecise ) {
	    //tmpf = log(fMix * baseLKs[k1] + (1.-fMix) * baseLKs[k2]);
	    tmpf = log(baseLKs[k1*3+k2]);
	    smMarkerLKs[k1*3+k2] += tmpf;
	    //rgMarkerLKs[rgIdx*9+k1*3+k2] += tmpf;
	  }
	  else {
	    //tmpf = (fMix * baseLKs[k1] + (1.-fMix) * baseLKs[k2]);
	    tmpf = baseLKs[k1*3+k2];
	    smMarkerLKs[k1*3+k2] *= tmpf; 
	    //rgMarkerLKs[rgIdx*9+k1*3+k2] *= tmpf;
	  }
	}
      }
    }

    // sample-level per-marker likelihood
    // smLLK = Pr(Data|fMix) = \prod_{markers} Pr(bases|fMix)
    //  = \prod_{markers} \sum_{G1,G2} Pr(bases|G1,G2,fMix) Pr(G1|AF)Pr(G2|AF)
    double perMarkerProb = 0;
    if ( pArgs->bPrecise ) {
      int maxIdx = 0;
      for(int k=1; k < 9; ++k) {
	if ( smMarkerLKs[maxIdx] < smMarkerLKs[k] ) {
	  maxIdx = k;
	}
      }
      for(int k1=0; k1 < 3; ++k1) {
	for(int k2=0; k2 < 3; ++k2) {
	  perMarkerProb += (exp(smMarkerLKs[k1*3+k2] - smMarkerLKs[maxIdx]) * genoFreq[k1] * genoFreq[k2]);
	}
      }
      smLLK += (log(perMarkerProb) + smMarkerLKs[maxIdx]);
    }
    else {
      for(int k1=0; k1 < 3; ++k1) {
	for(int k2=0; k2 < 3; ++k2) {
	  perMarkerProb += (smMarkerLKs[k1*3+k2] * genoFreq[k1] * genoFreq[k2]);
	}
      }
      smLLK += log(perMarkerProb);
    }

    /*
    for(int r=0; r < nRGs; ++r) {
      perMarkerProb = 0;
      if ( pArgs->bPrecise ) {
	int maxIdx = 0;
	for(int k=1; k < 9; ++k) {
	  if ( rgMarkerLKs[r*9+maxIdx] < rgMarkerLKs[r*9+k] ) {
	    maxIdx = k;
	  }
	}
	for(int k1=0; k1 < 3; ++k1) {
	  for(int k2=0; k2 < 3; ++k2) {
	    perMarkerProb += (exp(rgMarkerLKs[r*9+k1*3+k2] - rgMarkerLKs[r*9+maxIdx]) * genoFreq[k1] * genoFreq[k2]);
	  }
	}
	rgLLKs[r] += (log(perMarkerProb) + rgMarkerLKs[r*9+maxIdx]);
      }
      else {
	for(int k1=0; k1 < 3; ++k1) {
	  for(int k2=0; k2 < 3; ++k2) {
	    perMarkerProb += (rgMarkerLKs[r*9+k1*3+k2] * genoFreq[k1] * genoFreq[k2]);
	  }
	}
	rgLLKs[r] += log(perMarkerProb);
      }      
    }
    */
  }
//delete [] rgMarkerLKs;
Logger::gLogger->writeLog("double VerifyBamID::computeMixLLK( %.6lf | %.6lf, %.6lf, %.6lf ) = %.6lf for readGroup %d",fMix,pSN[0],pSN[1],pSN[2],smLLK,rgIdx);
  return smLLK;
}

// computeIBDLLKs() - calculate Pr(Data|fIBD) for each SM and RG
//                    given AF and call rate threshold
//double VerifyBamID::computeIBDLLKs(double fIBD, double* rgLLKs, int indIdx) {
double VerifyBamID::computeIBDLLKs(double fIBD, int indIdx, int rgIdx) {
  int nMarkers = (int)(pGenotypes->chroms.size());
  //int nRGs = (int)(pPile->vsRGIDs.size());
  double genoFreq[3], genoProb[3], baseLKs[9], smMarkerLKs[9];
  double af, baseError, baseMatch;
  char a1, a2, base;
  //int rgIdx;
  double smLLK = 0;
  double tmpf;
  //double* rgMarkerLKs = new double[nRGs*9];
  //memset(rgLLKs, 0, sizeof(double)*nRGs);

  //fprintf(stderr,"%d %d %d %d %d\n",pPile->nRGIndices.size(),pPile->cBases.size(),pPile->cQuals.size(),pPile->nBegins.size(),pPile->nEnds.size());
  //fprintf(stderr,"%d %d %d %d %d\n",pGenotypes->chroms.size(),pGenotypes->positions.size(),pGenotypes->alleleFrequencies.size(),pGenotypes->refBases.size(),pGenotypes->altBases.size());

  for(int i=0; i < nMarkers; ++i) {
    af = pGenotypes->alleleFrequencies[i];
    // force allele-frequency as nonzero to avoid boundary conditions
    if ( af < 0.001 ) af = 0.001;
    if ( af > 0.999 ) af = 0.999;

    // frequency of genotypes under HWE
    genoFreq[0] = (1.-af)*(1.-af);
    genoFreq[1] = 2.*af*(1.-af);
    genoFreq[2] = af*af;

    int geno = pGenotypes->getGenotype(indIdx,i);
    switch(geno) {
    case 0: // MISSING
      genoProb[0] = genoFreq[0];
      genoProb[1] = genoFreq[1];
      genoProb[2] = genoFreq[2];
      break;
    case 1: // HOMREF;
      genoProb[0] = 1.-pArgs->genoError;
      genoProb[1] = pArgs->genoError/2.;
      genoProb[2] = pArgs->genoError/2.;
      break;
    case 2: // HET;
      genoProb[0] = pArgs->genoError/2.;
      genoProb[1] = 1.-pArgs->genoError;
      genoProb[2] = pArgs->genoError/2.;
      break;
    case 3: // HET;
      genoProb[0] = pArgs->genoError/2.;
      genoProb[1] = pArgs->genoError/2.;
      genoProb[2] = 1.-pArgs->genoError;
      break;
    default:
      Logger::gLogger->error("Unrecognized genotype %d at ind %d, marker %d",indIdx,i);
    }

    a1 = pGenotypes->refBases[i];
    a2 = pGenotypes->altBases[i];

    // initialize the marker-level likelihoods
    for(int k=0; k < 9; ++k) {
      smMarkerLKs[k] = (pArgs->bPrecise ? 0. : 1.);
    }
    //for(int k=0; k < 9 * nRGs; ++k) {
    //  rgMarkerLKs[k] = (pArgs->bPrecise ? 0. : 1.);
    //}

    for(int j=(int)pPile->nBegins[i]; j < (int)pPile->nEnds[i]; ++j) {
      if ( ( rgIdx >= 0 ) && ( rgIdx != (int)pPile->nRGIndices[j] ) ) continue;

      // obtain b (base), (error), and readgroup info
      base = pPile->cBases[j];
      baseError = fPhred2Err[pPile->cQuals[j]-33];
      baseMatch = 1.-baseError;
      //rgIdx = static_cast<int>(pPile->nRGIndices[j]);

      for(int k1=0; k1 < 3; ++k1) {
	  for(int k2=0; k2 < 3; ++k2) {
	    baseLKs[k1*3+k2] = ( fIBD * pSN[0*3+k1] + (1.-fIBD) * pSN[0*3+k2] ) * ( base == a1 ? baseMatch : baseError/3.) + ( fIBD * pSN[1*3+k1] + (1.-fIBD) * pSN[1*3+k2] ) * ( base == a2 ? baseMatch : baseError/3. );
	  }
      }

      // merge base-level likelihood into marker-level likelihood
      // smMarkerLKs[i*3+j] 
      //   = \prod Pr(b|G1,G2) = \prod (f Pr(b|G1) + (1-f) Pr(b|G2))
      for(int k1=0; k1 < 3; ++k1) {
	for(int k2=0; k2 < 3; ++k2) {
	  if ( pArgs->bPrecise ) {
	    //tmpf = log(fMix * baseLKs[k1] + (1.-fMix) * baseLKs[k2]);
	    tmpf = log(baseLKs[k1*3+k2]);
	    smMarkerLKs[k1*3+k2] += tmpf;
	    //rgMarkerLKs[rgIdx*9+k1*3+k2] += tmpf;
	  }
	  else {
	    //tmpf = (fMix * baseLKs[k1] + (1.-fMix) * baseLKs[k2]);
	    tmpf = baseLKs[k1*3+k2];
	    smMarkerLKs[k1*3+k2] *= tmpf; 
	    //rgMarkerLKs[rgIdx*9+k1*3+k2] *= tmpf;
	  }
	}
      }
    }

    // sample-level per-marker likelihood
    // smLLK = Pr(Data|fMix) = \prod_{markers} Pr(bases|fMix)
    //  = \prod_{markers} \sum_{G1,G2} Pr(bases|G1,G2,fMix) Pr(G1|AF)Pr(G2|AF)
    double perMarkerProb = 0;
    if ( pArgs->bPrecise ) {
      int maxIdx = 0;
      for(int k=1; k < 9; ++k) {
	if ( smMarkerLKs[maxIdx] < smMarkerLKs[k] ) {
	  maxIdx = k;
	}
      }
      for(int k1=0; k1 < 3; ++k1) {
	for(int k2=0; k2 < 3; ++k2) {
	  perMarkerProb += (exp(smMarkerLKs[k1*3+k2] - smMarkerLKs[maxIdx]) * genoProb[k1] * genoFreq[k2]);
	}
      }
      smLLK += (log(perMarkerProb) + smMarkerLKs[maxIdx]);
    }
    else {
      for(int k1=0; k1 < 3; ++k1) {
	for(int k2=0; k2 < 3; ++k2) {
	  perMarkerProb += (smMarkerLKs[k1*3+k2] * genoProb[k1] * genoFreq[k2]);
	}
      }
      smLLK += log(perMarkerProb);
    }

    /*
    for(int r=0; r < nRGs; ++r) {
      perMarkerProb = 0;
      if ( pArgs->bPrecise ) {
	int maxIdx = 0;
	for(int k=1; k < 9; ++k) {
	  if ( rgMarkerLKs[r*9+maxIdx] < rgMarkerLKs[r*9+k] ) {
	    maxIdx = k;
	  }
	}
	for(int k1=0; k1 < 3; ++k1) {
	  for(int k2=0; k2 < 3; ++k2) {
	    perMarkerProb += (exp(rgMarkerLKs[r*9+k1*3+k2] - rgMarkerLKs[r*9+maxIdx]) * genoProb[k1] * genoFreq[k2]);
	  }
	}
	rgLLKs[r] += (log(perMarkerProb) + rgMarkerLKs[r*9+maxIdx]);
      }
      else {
	for(int k1=0; k1 < 3; ++k1) {
	  for(int k2=0; k2 < 3; ++k2) {
	    perMarkerProb += (rgMarkerLKs[r*9+k1*3+k2] * genoProb[k1] * genoFreq[k2]);
	  }
	}
	rgLLKs[r] += log(perMarkerProb);
      }      
    }
    */
  }
  //delete [] rgMarkerLKs;
  //Logger::gLogger->writeLog("double VerifyBamID::computeIBDLLK( %.6lf ) = %.6lf",fIBD,smLLK);
  Logger::gLogger->writeLog("double VerifyBamID::computeIBDLLK( %.6lf | %.6lf, %.6lf, %.6lf ) = %.6lf",fIBD,pSN[0],pSN[1],pSN[2],smLLK);
  return smLLK;
}

// computeIBDLLKs() - calculate Pr(Data|fIBD) for each SM and RG
//                    given AF and call rate threshold
void VerifyBamID::calculateDepthByGenotype(int indIdx, int rg, VerifyBamOut &vbo) {
  int nMarkers = (int)(pGenotypes->chroms.size());
  //int nRGs = (int)(pPile->vsRGIDs.size());

  for(int i=0; i < nMarkers; ++i) {
    int geno = pGenotypes->getGenotype(indIdx,i);
    int genoIdx = geno + 4*(rg+1);
    ++vbo.numGenos[genoIdx];
    if ( rg >= 0 ) {
      for(int j=(int)pPile->nBegins[i]; j < (int)pPile->nEnds[i]; ++j) {
	if ( ( rg >= 0 ) && ( rg != (int)pPile->nRGIndices[j] ) ) continue;
	++vbo.numReads[genoIdx];
      }
    }
    else {
      vbo.numReads[genoIdx] += ( pPile->nEnds[i] - pPile->nBegins[i] );
    }
  }
  return;
}

void VerifyBamID::calculateDepthDistribution(int maxDepth, VerifyBamOut &vbo) {
  std::vector<int> dps(nRGs+1,0);
  for(int i=0; i < nRGs+1; ++i) { vbo.numGenos[i*4] = nMarkers; }
  for(int i=0; i < nMarkers; ++i) {
    std::fill(dps.begin(), dps.end(), 0);
    for(int j=(int)pPile->nBegins[i]; j < (int)pPile->nEnds[i]; ++j) {
      int rg = (int)pPile->nRGIndices[j];
      ++dps[0];
      ++vbo.numReads[0];
      ++dps[rg+1];
      ++vbo.numReads[(rg+1)*4];
    }
    for(int j=0; j < nRGs+1; ++j) {
      if ( dps[j] > maxDepth ) {
	error("dps[%d] = %d > %d maxDepth",j,dps[j],maxDepth);
      }
      ++vbo.depths[dps[j] + j * (maxDepth+1)];
    }
  }
  return;
}

void VerifyBamID::printPerMarkerInfo(const char* filename, int indIdx) {
  IFILE oFile = ifopen(filename,"wb");
  int nMarkers = (int)(pGenotypes->chroms.size());
  char base, a1, a2;

  ifprintf(oFile,"#CHROM\tPOS\tA1\tA2\tAF\tGENO\t#REF\t#ALT\t#OTHERS\tBASES\tQUALS\tMAPQS\n");
  for(int i=0; i < nMarkers; ++i) {
    int counts[3] = {0,0,0};
    std::vector<char> bases;
    std::vector<char> quals;
    std::vector<char> mqs;

    ifprintf(oFile,"%s\t%d\t%c\t%c\t%.4lf\t",pGenotypes->chroms[i].c_str(),pGenotypes->positions[i],pGenotypes->refBases[i],pGenotypes->altBases[i],pGenotypes->alleleFrequencies[i]);
    int geno = pGenotypes->getGenotype(indIdx,i);
    switch(geno) {
    case 0: // MISSING
      ifprintf(oFile,"./.");
      break;
    case 1: // HOMREF;
      ifprintf(oFile,"0/0");
      break;
    case 2: // HET;
      ifprintf(oFile,"0/1");
      break;
    case 3: // HOMALT;
      ifprintf(oFile,"1/1");
      break;
    default:
      Logger::gLogger->error("Unrecognized genotype %d at ind %d, marker %d",indIdx,i);
    }

    a1 = pGenotypes->refBases[i];
    a2 = pGenotypes->altBases[i];

    for(int j=(int)pPile->nBegins[i]; j < (int)pPile->nEnds[i]; ++j) {
      // obtain b (base), (error), and readgroup info
      base = pPile->cBases[j];
      if ( base == a1 ) {
	++counts[0];
      }
      else if ( base == a2 ) {
	++counts[1];
      }
      else {
	++counts[2];
      }

      bases.push_back(base);
      quals.push_back(pPile->cQuals[j]);
      mqs.push_back(((uint8_t)(pPile->cMapQs[j]) > 90) ? '~' : static_cast<char>(pPile->cMapQs[j]+33));
    }
    ifprintf(oFile,"\t%d\t%d\t%d\t%.3lf\t",counts[0],counts[1],counts[2],(counts[0]+counts[1] == 0) ? 0.5 : (double)counts[0]/(double)(counts[0]+counts[1]));

    ifprintf(oFile,"\t");
    for(int j=0; j < (int)bases.size(); ++j)
      ifprintf(oFile,"%c",bases[j]);

    ifprintf(oFile,"\t");
    for(int j=0; j < (int)quals.size(); ++j)
      ifprintf(oFile,"%c",quals[j]);

    ifprintf(oFile,"\t");
    for(int j=0; j < (int)mqs.size(); ++j)
      ifprintf(oFile,"%c",mqs[j]);

    ifprintf(oFile,"\n");
  }
}
