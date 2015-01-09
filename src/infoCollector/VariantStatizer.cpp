#include <cmath>
#include <stdint.h>
#include <utility>
#include <algorithm>
//#include <boost/thread/mutex.hpp>

#define ZEPS 1e-10

#include "libVcfVcfFile.h"
#include "VariantStatizer.h"
#include "Logger.h"
using namespace libVcf;

double VariantStatizer::cor22(int a, int b, int c, int d) {
  // a b p
  // c d q
  // r s n
  int p = a+b+1;
  int q = c+d+1;
  int r = a+c+1;
  int s = b+d+1;
  double cor = ((a+.5)*(d+.5)-(b+.5)*(c+.5))/sqrt((double)p*q*r*s);
  return cor;
}

double VariantStatizer::qcor(double sumA, double sumSqA, double sumB, double sumSqB, double sumAB, int n) {
  double varA = sumSqA/n - sumA*sumA/n/n;
  double varB = sumSqB/n - sumB*sumB/n/n;
  double covAB = sumAB/n - sumA*sumB/n/n;

  //fprintf(stderr,"qcor(%f,%f,%f,%f,%f,%f,%f,%d)]\n",sumA,sumSqA,sumB,sumSqB,sumAB,varA,varB,covAB,n);
  //abort();
  if ( ( varA <= 0 ) || ( varB <= 0 ) || ( n == 0 ) ) {
    return 0;
  }
  else {
    double r = covAB/sqrt(varA*varB + ZEPS);
    return r;
  }
}

bool VariantStatizer::loadAnchorVcf(const char* file) {
  anchorVcf.setSiteOnly(true);
  anchorVcf.openForRead(file,1);
  return true;
}

// add a VCF file to calculate the stats
bool VariantStatizer::appendStatVcf(const char* file) {
  // open VCF file
  VcfFile* pVcf = new VcfFile;
  pVcf->setSiteOnly(false);
  pVcf->setParseValues(true);
  pVcf->setParseGenotypes(false);
  pVcf->setParseDosages(false);
  pVcf->openForRead(file,1);

  // allocate space for markers
  uint8_t* pcBase = new uint8_t[MAX_READS_PER_BASE];
  uint8_t* pcMapQ = new uint8_t[MAX_READS_PER_BASE];
  uint8_t* pcQual = new uint8_t[MAX_READS_PER_BASE];
  uint8_t* pcStrand = new uint8_t[MAX_READS_PER_BASE];
  uint16_t* pcCycle = new uint16_t[MAX_READS_PER_BASE];
  //uint16_t* pcHash = new uint16_t[MAX_READS_PER_BASE];

  pPileVcfs.push_back(pVcf);
  nReads.push_back(0);
  pcBases.push_back(pcBase);
  pcMapQs.push_back(pcMapQ);
  pcQuals.push_back(pcQual);
  pcStrands.push_back(pcStrand);
  pcCycles.push_back(pcCycle);
  //pcHashes.push_back(pcHash);
  for(int i=0; i < 10; ++i) {
    nPLs.push_back(0);
  }

  return pVcf->iterateMarker(); // read first marker
}

bool VariantStatizer::advancePileVcf(int index) {
  // check whether current position is read
  // if no marker has been read, read one

  VcfFile* pVcf = pPileVcfs[index];
  VcfMarker* pMarker = pVcf->getLastMarker();
  while( (pMarker != NULL) && (pMarker->nPos < anchorPos) ) {
    pVcf->iterateMarker();
    pMarker = pVcf->getLastMarker();
  }
  if ( pVcf->bEOF ) {
    nReads[index] = 0;  // no read is written
    return false;
  }
  else if ( pMarker->nPos == anchorPos ) {
    return readMarker(index, pMarker);
  }
  else {
    nReads[index] = 0;  // no read is written
    return false;
  }
}

bool VariantStatizer::readMarker(int index, VcfMarker* pMarker) {
  if ( pMarker == NULL ) {
    return false;
  }

  StringArray tok;
  for(int k=0; k < pMarker->asFormatKeys.Length(); ++k) {
    if ( pMarker->asFormatKeys[k].Compare("N") == 0 ) {
      nReads[index] = pMarker->asSampleValues[k].AsInteger();
      if ( nReads[index] >= MAX_READS_PER_BASE ) {
	Logger::gLogger->warning("Exceesive # of BASES %d at %s:%d in index %d",nReads[index],pMarker->sChrom.c_str(),pMarker->nPos,index);
	nReads[index] = MAX_READS_PER_BASE;
      }
    }
    else if ( pMarker->asFormatKeys[k].Compare("BASE") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of BASE does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	uint8_t cBase = vBase2Num[(int)tok[l][0]];
	if ( cBase == 0 ) {
	  Logger::gLogger->error("Cannot recognize base %s",tok[l].c_str());	    
	}
	pcBases[index][l] = cBase;
      }
    }
    else if ( pMarker->asFormatKeys[k].Compare("MAPQ") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of MAPQ does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	pcMapQs[index][l] = (uint8_t)(tok[l].AsInteger());
      }
    }    
    else if ( pMarker->asFormatKeys[k].Compare("BASEQ") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of BASEQ does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	pcQuals[index][l] = (uint8_t)(tok[l].AsInteger());
      }
    }
    else if ( pMarker->asFormatKeys[k].Compare("STRAND") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of STRAND does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	switch(tok[l][0]) {
	case 'F':
	  pcStrands[index][l] = 0;
	  break;
	case 'R':
	  pcStrands[index][l] = 1;
	  break;
	default:
	  Logger::gLogger->error("Unrecognized STRAND %s at %s:%d",tok[l].c_str(),pMarker->sChrom.c_str(),pMarker->nPos);
	}
      }
    }
    else if ( pMarker->asFormatKeys[k].Compare("CYCLE") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of CYCLE does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	pcCycles[index][l] = (uint16_t)(tok[l].AsInteger());
	//fprintf(stderr,"index=%d l=%d cycles=%d\n",index,l,pcCycles[index][l]);
      }
    }
    /*
    else if ( pMarker->asFormatKeys[k].Compare("RHASH") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of RHASH does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	pcHashes[index][l] = (uint16_t)(tok[l].AsInteger());
      }
    }
    */
    else if ( ( pMarker->asFormatKeys[k].Compare("PL") == 0 ) || ( pMarker->asFormatKeys[k].Compare("PL") == 0 ) ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( tok.Length() != 10 ) {
	Logger::gLogger->error("# of CYCLE does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; l < 10; ++l) {
	nPLs[index*10+l] = tok[l].AsInteger();
      }
    }
  }
  return true;
}

std::pair<double,double> VariantStatizer::estimateAF(double eps) {
  // initialization : pick an arbitrary AF from 
  std::vector<int>::iterator it;
  int i, c, n, r, i0, i1, i2;
  double p = .5 + rand()/(RAND_MAX+1.)*.3; // start with random AF
  double q;
  double f0,f1,f2, fsum, sum;
  double llk = 0;
  std::vector<double> post;
  n = (int)pPileVcfs.size();
  post.resize(n*3);
  
  // 0,1,2,3 -> 0,4,7,9 -> 0, 4, 4+3, 4+3+2 -> (3+x)*x+x 
  i0 = (10-anchorAl1)*(anchorAl1-1)/2;
  i1 = anchorAl1 > anchorAl2 ? (10-anchorAl2)*(anchorAl2-1)/2+(anchorAl1-anchorAl2) : (10-anchorAl1)*(anchorAl1-1)/2+(anchorAl2-anchorAl1);
  i2 = (10-anchorAl2)*(anchorAl2-1)/2;

  for(r = 0; r < 100; ++r) {
    sum = 0;
    c = 0;
    q = 1.-p;
    for(i=0; i < n; ++i) {
      f0 = q * q * vPhred2Err[nPLs[i*10 + i0]];
      f1 = 2. * p * q * vPhred2Err[nPLs[i*10 + i1]];
      f2 = p * p * vPhred2Err[nPLs[i*10 + i2]];
      fsum = f0+f1+f2;
      post[c++] = f0/fsum;
      sum += (post[c++] = f1/fsum);
      sum += (2 * (post[c++] = f2/fsum));
    }
    p = sum / (2*n);
    if ( fabs(p + q - 1.) < eps ) break;
  }
  
  // Pr(Data|AF) = \sum_g Pr(Data|g)Pr(g|AF)
  q = 1.-p;
  for(int i=0; i < (int)pPileVcfs.size(); ++i) {
    f0 = q * q * vPhred2Err[nPLs[i*10 + i0]];
    f1 = 2. * p * q * vPhred2Err[nPLs[i*10 + i1]];
    f2 = p * p * vPhred2Err[nPLs[i*10 + i2]];
    fsum = f0+f1+f2;
    llk += log(fsum);
  }
  return std::pair<double,double>(p,llk);
}


bool VariantStatizer::writeMergedVcf(const char* outFile) {
  IFILE oFile = ifopen(outFile,"wb");
  if ( oFile == NULL ) {
    Logger::gLogger->error("Cannot open output file %s",outFile);
  }

  // add additional INFO columns into the header
  for(int i=1; i < anchorVcf.asMetaKeys.Length(); ++i) {
    if ( (anchorVcf.asMetaKeys[i-1].SubStr(0,4).Compare("INFO") == 0) && (anchorVcf.asMetaKeys[i].SubStr(0,4).Compare("INFO") != 0) ) {
      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=STR,Number=1,Type=Float,Description=\"Strand Bias Pearson's Correlation\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=STZ,Number=1,Type=Float,Description=\"Strand Bias z-score\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=CBR,Number=1,Type=Float,Description=\"Cycle Bias Peason's correlation\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=CBZ,Number=1,Type=Float,Description=\"Cycle Bias z-score\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=CSR,Number=1,Type=Float,Description=\"Cycle-Strand Peason's Correlation\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=IOZ,Number=1,Type=Float,Description=\"Base quality inflation z-score\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=IOR,Number=1,Type=Float,Description=\"Ratio of base-quality inflation\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=AOZ,Number=1,Type=Float,Description=\"Alternate allele quality z-score\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=AOI,Number=1,Type=Float,Description=\"Alternate allele inflation score\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=LQR,Number=1,Type=Float,Description=\"LQR\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=MQ0,Number=1,Type=Float,Description=\"Fraction of bases with mapQ=0\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=MQ10,Number=1,Type=Float,Description=\"Fraction of bases with mapQ<=10\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=MQ20,Number=1,Type=Float,Description=\"Fraction of bases with mapQ<=20\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=MQ30,Number=1,Type=Float,Description=\"Fraction of bases with mapQ<=30\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=LBS,Number=8,Type=Integer,Description=\"LBS\">");
      ++i;

      anchorVcf.asMetaKeys.InsertAt(i,"INFO");
      anchorVcf.asMetaValues.InsertAt(i,"<ID=OBS,Number=8,Type=Integer,Description=\"OBS\">");
      ++i;
    }
  }

  // create output VCF
  anchorVcf.printVCFHeader(oFile);

  while( anchorVcf.iterateMarker() ) {
    // parse anchor VCF
    pCurrentMarker = anchorVcf.getLastMarker();

    //Logger::gLogger->writeLog("%s:%d",pCurrentMarker->sChrom.c_str(),pCurrentMarker->nPos);

    anchorPos = pCurrentMarker->nPos;
    if ( pCurrentMarker->asAlts.Length() > 1 ) {
      anchorAl1 = vBase2Num[(int)pCurrentMarker->asAlts[0][0]];
      anchorAl2 = vBase2Num[(int)pCurrentMarker->asAlts[1][0]];
    }
    else {
      anchorAl1 = vBase2Num[(int)pCurrentMarker->sRef[0]];
      anchorAl2 = vBase2Num[(int)pCurrentMarker->asAlts[0][0]];
    }

    //Logger::gLogger->writeLog("foo1");

    /*
    for(int j=0; j < pCurrentMarker->asAlts.Length(); ++j) {
      anchorAlts.push_back(vBase2Num[(int)pCurrentMarker->asAlts[j][0]]);
    }
    */
    anchorAF = -1;

    for(int j=0; j < pCurrentMarker->asInfoKeys.Length(); ++j) {
      if ( pCurrentMarker->asInfoKeys[j].Compare("AF") == 0 ) {
	if ( pCurrentMarker->asAlts.Length() > 1 ) {
	  StringArray tok;
	  tok.ReplaceColumns(pCurrentMarker->asInfoValues[j],',');
	  anchorAF = tok[1].AsDouble();
	}
	else {
	  anchorAF = pCurrentMarker->asInfoValues[j].AsDouble();
	}
	break;
      }
    }

    int anchorAC = -1;
    for(int j=0; j < pCurrentMarker->asInfoKeys.Length(); ++j) {
      if ( pCurrentMarker->asInfoKeys[j].Compare("AC") == 0 ) {
	if ( pCurrentMarker->asAlts.Length() > 1 ) {
	  StringArray tok;
	  tok.ReplaceColumns(pCurrentMarker->asInfoValues[j],',');
	  anchorAC = tok[1].AsInteger();
	}
	else {
	  anchorAC = pCurrentMarker->asInfoValues[j].AsInteger();
	}
	break;
      }
    }

    if ( anchorAF < 0 ) {
      Logger::gLogger->warning("Cannot find AF in the INFO field at the first marker");
    }
    else if ( anchorAF == 0 ) {
      anchorAF = 1e-6;
    }
    

    // advance each pile VCF
    for(int i=0; i < (int)pPileVcfs.size(); ++i) {
      advancePileVcf(i);
    }

    //Logger::gLogger->writeLog("foo3");

    writeCurrentMarker(oFile);
  }
  ifclose(oFile);
  return true;
}

/*
void VariantStatizer::writeCurrentMarker(IFILE oFile) {
  VcfMarker* pMarker = anchorVcf.getLastMarker();

  // determine anchorO1 and anchorO2 for biallelic SNPs
  int flags[4] = {0,0,0,0};
  flags[anchorAl1-1] = flags[anchorAl2-1] = 1;
  int anchorO1 = -1, anchorO2 = -1;
  for(int i=0; i < 4; ++i) {
    if ( flags[i] == 0 ) {
      anchorO1 = i+1;
      flags[i] = 1;
      break;
    }
  }
  for(int i=0; i < 4; ++i) {
    if ( flags[i] == 0 ) {
      anchorO2 = i+1;
      break;
    }
  }

  // collect base level information
  int* lBS = new int[8]();  // # lowQual bases/strand
  int* oBS = new int[8]();  // # HQ bases/strands
  double* eBS = new double[8](); // # expected bases/strands
  int* q1BS = new int[8](); // sum of BQs
  int* q2BS = new int[8](); // sqsum of BAQs
  int* m1BS = new int[8](); // sum of MQs
  int* m2BS = new int[8](); // sqsum of MQs
  int* c1BS = new int[8](); // sum of CYCLES
  int* c2BS = new int[8](); // sqsum of CYCLES
  int* mHist = new int[256](); // histogram of mapQs

  int b, s, m, q, c;
  double e, e3, cm, ch, t;
  double ve = 0, llkSNP = 0, llkNull = 0;
  double logThird = 0-log10(3);
  double eHET = 0, rHET = 0, oHET = 0, h = 0, vHET = 0;
  int nSM = 0;

  int nvcfs = (int)pPileVcfs.size();
  uint8_t* PLs = new (uint8_t)[nvcfs * 3]

  for(int i=0; i < nvcfs; ++i) {
    double GLs[3] = {0,0,0};
    int oSM[4] = {0,0,0,0};
    for(int j=0; j < nReads[i]; ++j) {
      b = pcBases[i][j];   // base
      s = pcStrands[i][j]; // strand
      m = pcMapQs[i][j];   // mapQ
      q = pcQuals[i][j];   // baseQ
      c = pcCycles[i][j];  // cycle
      e = vPhred2Err[q];   // error is the probability of mismatch
      e3 = e/3.;
      cm = vPhred2Match[q]; // cm is the probability of match
      ch = vPhred2Het[q];   // ch is the probability of heterozygoisy

      if ( ( b > 0 ) && ( b < 5 ) ) { // A,C,G,T
	if ( q < 13 ) {      // do not use low quality reads to calculate GLs
	  ++lBS[(b-1)*2+s];
	}
	else {
	  ++oBS[(b-1)*2+s];  // fill out the statistics
	  ++oSM[(b-1)];
	  q1BS[(b-1)*2+s] += q;
	  q2BS[(b-1)*2+s] += (q*q);
	  m1BS[(b-1)*2+s] += m;
	  m2BS[(b-1)*2+s] += (m*m);	  
	  c1BS[(b-1)*2+s] += c;
	  c2BS[(b-1)*2+s] += (c*c);
	  eBS[(b-1)*2+s] += (1.-e);
	  for(int k=0; k < 4; ++k) {
	    if ( k != b-1 ) {
	      eBS[k*2+s] += e3;
	    }
	  }
	  ve += (e3*(1.-e3));
	  ++mHist[m];

	  // Calculate the genotype likelihood
	  if ( b == anchorAl1 ) {
	    GLs[0] += cm;  // cm = log10(1-e)
	    GLs[1] += ch;  // ch = log10(0.5-e/3)
	    GLs[2] += (-0.1*q + logThird); // log10(e) + log(1/3) = log10(e/3)
	  }
	  else if ( b == anchorAl2 ) {
	    GLs[0] += (-0.1*q + logThird);
	    GLs[1] += ch;
	    GLs[2] += cm;
	  }
	  //else {
	  //  GLs[0] += (-0.1*q+logThird);
	  //  GLs[1] += (-0.1*q+logThird);
	  //  GLs[2] += (-0.1*q+logThird);
	  //}
	  llkNull += ((b == anchorAl1) ? cm : (-0.1*q + logThird));
	  //if ( b != anchorAl1 ) {
	  //  llkNull += (-0.1*q + logThird);
	    //}
	}
      }
    }
    PLs[3*i] = (GLs[0] < -25.5) ? 255 : (int)(-10*GLs[0]+.5);
    PLs[3*i+1] = (GLs[1] < -25.5) ? 255 : (int)(-10*GLs[1]+.5);
    PLs[3*i+2] = (GLs[2] < -25.5) ? 255 : (int)(-10*GLs[2]+.5);
  }

  {
    // estimate AF using EM
    int r;
    double p = .5 + rand()/(RAND+MAX+1.)*.3;
    double q;
    double f0, f1, f2, fsum, sum;
    double eps = 1e-6;

    for(r=0; r < 100; +=r) {
      sum = 0;
      c = 0;
      q = 1.-p;
      for(int i=0; i < nvcfs; ++i) {
	f0 = q * q * vPhred2Err[PLs[3*i]];
	f1 = 2. * p * q * vPhred2Errr[PLs[3*i+1]];
	f2 = p * p * vPhred2Errr[PLs[3*i+2]];
	fsum = f0+f1+f2;
	sum += (f1/fsum);
	sum += (2 *f2/fsum);
      }
      p = sum / (2*nvcfs);
      if ( fabs(p + q - 1.) < eps ) break;    
    }

    q = 1.-p;

    // calculate inbreeding coefficients
    
  }

    // calculate llkSNP
    if ( GLs[0] > GLs[1] ) {
      if ( GLs[0] > GLs[2] ) { // GLs[0] is the largest
	t = (1.-anchorAF)*(1.-anchorAF) + 2.*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[0]) + anchorAF*anchorAF*pow(10.,GLs[2]-GLs[0]);
	llkSNP += (GLs[0] + log10(t));
	h = (2*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[0])/t);
      }
      else { // GLs[2] is the largest
	t = (1.-anchorAF)*(1.-anchorAF)*pow(10.,GLs[0]-GLs[2]) + 2.*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2]) + anchorAF*anchorAF;
	llkSNP += (GLs[2] + log10(t));
	h = (2*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2])/t);
      }
    }
    else {
      if ( GLs[1] > GLs[2] ) { // GLs[1] is the largest
	t = (1.-anchorAF)*(1.-anchorAF)*pow(10.,GLs[0]-GLs[1]) + 2.*anchorAF*(1.-anchorAF) + anchorAF*anchorAF*pow(10.,GLs[2]-GLs[1]);
	llkSNP += (GLs[1] + log10(t));
	h = (2*anchorAF*(1.-anchorAF)/t);
      }
      else { // GLs[2] is the largest
	t = (1.-anchorAF)*(1.-anchorAF)*pow(10.,GLs[0]-GLs[2]) + 2.*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2]) + anchorAF*anchorAF;
	llkSNP += (GLs[2] + log10(t));
	h = (2*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2])/t);	
      }
    }
    if ( (oSM[anchorAl1-1] + oSM[anchorAl2-1]) > 0 ) {
      ++nSM;
      eHET += h;
      rHET += (h * oSM[anchorAl1-1] / (double)(oSM[anchorAl1-1] + oSM[anchorAl2-1]));
      oHET += (h * (oSM[anchorO1-1] + oSM[anchorO2-1]) / (double)(oSM[anchorAl1-1] + oSM[anchorAl2-1] + oSM[anchorO1-1] + oSM[anchorO2-1]));
      vHET += h * h / (2. * (oSM[anchorAl1-1] + oSM[anchorAl2-1]));
    }
}
*/

void VariantStatizer::writeCurrentMarker(IFILE oFile) {
  VcfMarker* pMarker = anchorVcf.getLastMarker();

  //fprintf(stderr,"foo %d\n",anchorPos);
  
  // determine anchorO1 and anchorO2
  int flags[4] = {0,0,0,0};
  flags[anchorAl1-1] = flags[anchorAl2-1] = 1;
  int anchorO1 = -1, anchorO2 = -1;
  for(int i=0; i < 4; ++i) {
    if ( flags[i] == 0 ) {
      anchorO1 = i+1;
      flags[i] = 1;
      break;
    }
  }
  for(int i=0; i < 4; ++i) {
    if ( flags[i] == 0 ) {
      anchorO2 = i+1;
      break;
    }
  }

  // basic read-level statistics
  // lBS : [A,C,G,T] * [F,B] observed counts at bq < 13
  // oBS : [A,C,G,T] * [F,B] observed counts at bq >= 13
  // eBS : [A,C,G,T] * [F,B] expected counts at bq >= 13
  // q1BS : [A,C,G,T] * [F,B] sum bq at bq >= 13
  // q2BS : [A,C,G,T] * [F,B] sum bq^2 at bq >= 13
  // m1BS : [A,C,G,T] * [F,B] sum mapQ at bq >= 13
  // m2BS : [A,C,G,T] * [F,B] sum mapQ^2 at bq >= 13
  // c1BS : [A,C,G,T] * [F,B] sum cycle at bq >= 13
  // c2BS : [A,C,G,T] * [F,B] sum cycle^2 at bq >= 13
  int* lBS = new int[8]();
  int* oBS = new int[8]();
  double* eBS = new double[8]();
  /*
  int* q1BS = new int[8]();
  int* q2BS = new int[8]();
  int* m1BS = new int[8]();
  int* m2BS = new int[8]();
  */
  double* c1BS = new double[8]();
  double* c2BS = new double[8]();
  //int* hashes = new int[65536]();
  int* mHist = new int[256]();

  std::fill(lBS,lBS+8,0);
  std::fill(oBS,oBS+8,0);
  std::fill(eBS,eBS+8,0);
  std::fill(c1BS,c1BS+8,0);
  std::fill(c2BS,c2BS+8,0);
  //std::fill(hashes,hashes+65536,0);
  std::fill(mHist,mHist+256,0);

  int b, s, m, q, c;
  uint16_t hs;
  double e, e3, cm, ch; //, t;
  double ve = 0; //, llkSNP = 0, llkNull = 0;
  //double logThird = 0-log10(3.);
  double eHET = 0, rHET = 0, oHET = 0, h = 0, vHET = 0;
  //double oHET = 0, eHET = 0, rHET = 0;
  //int nSM = 0;
  int nDupAlts = 0;
  int nNonDupAlts = 0;
  int qDupAlts = 0;

  int i0 = (10-anchorAl1)*(anchorAl1-1)/2;
  int i1 = anchorAl1 > anchorAl2 ? (10-anchorAl2)*(anchorAl2-1)/2+(anchorAl1-anchorAl2) : (10-anchorAl1)*(anchorAl1-1)/2+(anchorAl2-anchorAl1);
  int i2 = (10-anchorAl2)*(anchorAl2-1)/2;

  // adjust PLs
  for(int i=0; i < (int)pPileVcfs.size(); ++i) {
    int minPL = nPLs[i*10 + i0];
    if ( minPL > nPLs[i*10 + i1] ) { minPL = nPLs[i*10 + i1]; }
    if ( minPL > nPLs[i*10 + i2] ) { minPL = nPLs[i*10 + i2]; }
      
    nPLs[i*10 + i0] -= minPL;
    nPLs[i*10 + i1] -= minPL;
    nPLs[i*10 + i2] -= minPL;

    if ( nPLs[i*10+i0] > 100 ) { nPLs[i*10+i0] = 100; }
    if ( nPLs[i*10+i1] > 100 ) { nPLs[i*10+i1] = 100; }
    if ( nPLs[i*10+i2] > 100 ) { nPLs[i*10+i2] = 100; }
  }

  // estimate allele frequency
  std::pair<double,double> pa = estimateAF(1e-6);
  emAF = pa.first;

  for(int i=0; i < (int)pPileVcfs.size(); ++i) {
    //double GLs[3] = {0,0,0};
    int oSM[4] = {0,0,0,0};

    bool dupFlag = false;
    int max_dup_q = 0;

    int nrDups = 0;
    int nrAlts = 0;

    for(int j=0; j < nReads[i]; ++j) {
      b = pcBases[i][j];   // base
      s = pcStrands[i][j]; // strand
      m = pcMapQs[i][j];   // mapQ
      q = pcQuals[i][j];   // baseQ
      c = ((pcCycles[i][j] > 50) ? (100-(int)pcCycles[i][j]) : (int)pcCycles[i][j]);  // cycle to the tail
      if ( abs(c) > 100 ) c = 0;
      //fprintf(stderr,"i=%d j=%d c=%d\n",i,j,c);
      //hs = pcHashes[i][j];  // hash
      e = vPhred2Err[q];   // error is the probability of mismatch
      e3 = e/3.;
      cm = vPhred2Match[q]; // cm is the probability of match
      ch = vPhred2Het[q];   // ch is the probability of heterozygoisy

      // check overlaping fragment with non-ref alleles
      /*
      if ( b == anchorAl2 ) {
	++nrAlts;
	if ( hashes[hs] == 0 ) {
	  hashes[hs] = q;
	}
	else {
	  dupFlag = true;
	  nrDups += 2;
	  if ( max_dup_q < hashes[hs] + q ) {
	    max_dup_q = hashes[hs] + q;
	  }
	}
      }
      */

      if ( ( b > 0 ) && ( b < 5 ) ) {
	if ( q < 13 ) {      // do not use low quality reads to calculate GLs
	  ++lBS[(b-1)*2+s];
	}
	else {
	  ++oBS[(b-1)*2+s];
	  ++oSM[(b-1)];
	  //q1BS[(b-1)*2+s] += q;
	  //q2BS[(b-1)*2+s] += (q*q);
	  //m1BS[(b-1)*2+s] += m;
	  //m2BS[(b-1)*2+s] += (m*m);	  
	  c1BS[(b-1)*2+s] += ((double)c);
	  c2BS[(b-1)*2+s] += ((double)(c*c));

	  //fprintf(stderr,"i=%d, j=%d, b=%d, c = %d, s=%d, c1BS=%f\n",i,j,b,c,s,c1BS[(b-1)*2+s]);
	  //abort();
  
	  //eBS[(b-1)*2+s] += (1.-e);
	  for(int k=0; k < 4; ++k) {
	    //if ( k != b-1 ) {
	    eBS[k*2+s] += e3;
	      //}
	  }
	  ve += (e3*(1.-e3));
	  ++mHist[m];

	  
	  // Calculate the genotype likelihood
	  //if ( b == anchorAl1 ) {
	  //  GLs[0] += cm;  // cm = log10(1-e)
	  //  GLs[1] += ch;  // ch = log10(0.5-e/3)
	  //  GLs[2] += (-0.1*q + logThird); // log10(e) + log(1/3) = log10(e/3)
	  //}
	  //else if ( b == anchorAl2 ) {
	  //  GLs[0] += (-0.1*q + logThird);
	  //  GLs[1] += ch;
	  //  GLs[2] += cm;
	  //}
	  //else {
	  //  GLs[0] += (-0.1*q+logThird);
	  //  GLs[1] += (-0.1*q+logThird);
	  //  GLs[2] += (-0.1*q+logThird);
	  //}
	  //llkNull += ((b == anchorAl1) ? cm : (-0.1*q + logThird));
	  //if ( b != anchorAl1 ) {
	  //  llkNull += (-0.1*q + logThird);
	    //}
	}
      }
    }

    if ( dupFlag ) {
      ++nDupAlts;
      if ( qDupAlts < max_dup_q ) qDupAlts = max_dup_q;
    }
    if ( oSM[anchorAl2-1] > nrDups ) {
      ++nNonDupAlts;
    }

    // calculate llkSNP

    double fp = emAF;
    double fq = 1.-emAF;

    // calculate inbreeding cofficient
    double f0 = fq * fq * vPhred2Err[nPLs[i*10+i0]];
    double f1 = 2. * fp * fq * vPhred2Err[nPLs[i*10+i1]];
    double f2 = fp * fp * vPhred2Err[nPLs[i*10+i2]];

    if ( (oSM[anchorAl1-1] + oSM[anchorAl2-1]) > 0 ) {
      eHET += 2. * fp * fq;
      h = f1/(f0+f1+f2);
      oHET += h ;
      rHET += (h * oSM[anchorAl1-1] / (double)(oSM[anchorAl1-1] + oSM[anchorAl2-1] ));
      vHET += (h * h / (2. * (oSM[anchorAl1-1] + oSM[anchorAl2-1] + ZEPS)));
    }

    //memset(hashes,0,sizeof(int)*65536);
    
    /*

    if ( GLs[0] > GLs[1] ) {
      if ( GLs[0] > GLs[2] ) { // GLs[0] is the largest
	t = fq * fq + 2. * fp * fq * pow(10.,GLs[1]-GLs[0]) + fp * fp *pow(10.,GLs[2]-GLs[0]);
	llkSNP += (GLs[0] + log10(t));
	h = (2 * fp * fq * pow(10.,GLs[1]-GLs[0])/t); // Pr(Het|Data)
      }
      else { // GLs[2] is the largest
	t = fq * fq *pow(10.,GLs[0]-GLs[2]) + 2.* fp * fq *pow(10.,GLs[1]-GLs[2]) + fp * fp;
	llkSNP += (GLs[2] + log10(t));
	h = (2 * fp * fq * pow(10.,GLs[1]-GLs[2])/t); // Pr
      }
    }
    else {
      if ( GLs[1] > GLs[2] ) { // GLs[1] is the largest
	t = fq * fq * pow(10.,GLs[0]-GLs[1]) + 2.* fp * fq + fp * fp * pow(10.,GLs[2]-GLs[1]);
	llkSNP += (GLs[1] + log10(t));
	h = (2 * fp * fq /t);
      }
      else { // GLs[2] is the largest
	t = fq * fq *pow(10.,GLs[0]-GLs[2]) + 2. * fp * fq *pow(10.,GLs[1]-GLs[2]) + fp * fp;
	llkSNP += (GLs[2] + log10(t));
	h = (2 * fp * fq * pow(10.,GLs[1]-GLs[2])/t);	
      }
    }

    if ( (oSM[anchorAl1-1] + oSM[anchorAl2-1]) > 0 ) {
      ++nSM;
      eHET += h;
      rHET += (h * oSM[anchorAl1-1] / (double)(oSM[anchorAl1-1] + oSM[anchorAl2-1]));
      oHET += (h * (oSM[anchorO1-1] + oSM[anchorO2-1]) / (double)(oSM[anchorAl1-1] + oSM[anchorAl2-1] + oSM[anchorO1-1] + oSM[anchorO2-1]));
      vHET += h * h / (2. * (oSM[anchorAl1-1] + oSM[anchorAl2-1]));
    }
    //fprintf(stderr,"eHet = %lf, rHet = %lf, (%d,%d,%d,%d), (%.3lf,%.3lf,%.3lf)\n",eHET,rHET,oSM[0],oSM[1],oSM[2],oSM[3],GLs[0],GLs[1],GLs[2]);
    */
  }

  // individual level statistics
  // PLs : Pr[Data|AA,AC,AG,AT,CC,CG,CT,GG,GT,TT] at bq>=13
  // GDs : # [A,C,G,T] * [F,B]
  //
  // calculate statistics
  // STR : Strand Bias r : cor(oBS[R,F],oBS[R,B],oBS[A,F],oBS[A,B])
  // STZ : Strand Bias z : z(oBS[R,F],oBS[R,B],oBS[A,F],oBS[A,B])
  // CBR : Cycle Bias r : cor(c[R,FB],c[A,FB])
  // CBZ : Cycle Bias z : z(c[R,FB],c[A,FB])
  // MBR : Mapping Quality r : cor(m[R,FB],m[A,FB])
  // MBZ : Mapping Quality z : z(m[R,FB],m[A,FB])
  // QBR : Base Quality r : cor(q[R,FB],q[A,FB])
  // QBZ : Base Quality r : z(q[R,FB],q[A,FB])
  // IOR : E[~RA|Data]/E[~RA]
  // IOZ : (E[~RA|Data]-E[~RA])/var(..)
  // AOI : (E[A|Data,AF]-E[A|NULL])/var(..)
  // AOZ : AOI-IOZ
  //
  // ABE : Expected allele balance : E[R|HET,Data]
  //       Pr(R|HET)
  // ABZ : Expected allele z score : (E[R|HET,Data]-E[R|HET])/var(..)
  // calculate statistics
  // STR : r2(#RF,#RB,#AF,#AB)
  // STZ : z(#RF,#RB,#AF,#AB)
  // CBR : r2(#RC,#AC)
  // CSR : r2(#FC,#BC)
  // FIC : Inbreeding coefficient 

  //fprintf(stderr,"bar %d\n",anchorPos);

  int N = (oBS[(anchorAl1-1)*2+0]+oBS[(anchorAl1-1)*2+1]+oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1]);
  int Nl = (lBS[(anchorAl1-1)*2+0]+lBS[(anchorAl1-1)*2+1]+lBS[(anchorAl2-1)*2+0]+lBS[(anchorAl2-1)*2+1]);
  double sqrtN = sqrt((double)N);
  double fSTR = cor22(oBS[(anchorAl1-1)*2+0], oBS[(anchorAl1-1)*2+1], oBS[(anchorAl2-1)*2+0], oBS[(anchorAl2-1)*2+1]);
  double fSTZ = fSTR * sqrtN;
  double fCBR = qcor( c1BS[(anchorAl1-1)*2+0]+c1BS[(anchorAl1-1)*2+1]+c1BS[(anchorAl2-1)*2+0]+c1BS[(anchorAl2-1)*2+1], 
		      c2BS[(anchorAl1-1)*2+0]+c2BS[(anchorAl1-1)*2+1]+c2BS[(anchorAl2-1)*2+0]+c2BS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1], 
		      c1BS[(anchorAl2-1)*2+0]+c1BS[(anchorAl2-1)*2+1],
		      N
		      );
  double fCBZ = fCBR * sqrtN;
  /*
  double fQBR = qcor( q1BS[(anchorAl1-1)*2+0]+q1BS[(anchorAl1-1)*2+1]+q1BS[(anchorAl2-1)*2+0]+q1BS[(anchorAl2-1)*2+1], 
		      q2BS[(anchorAl1-1)*2+0]+q2BS[(anchorAl1-1)*2+1]+q2BS[(anchorAl2-1)*2+0]+q2BS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1], 
		      q1BS[(anchorAl2-1)*2+0]+q1BS[(anchorAl2-1)*2+1],
		      N
		      );
  double fQBZ = fQBR * sqrtN;
  double fMBR = qcor( m1BS[(anchorAl1-1)*2+0]+m1BS[(anchorAl1-1)*2+1]+m1BS[(anchorAl2-1)*2+0]+m1BS[(anchorAl2-1)*2+1], 
		      m2BS[(anchorAl1-1)*2+0]+m2BS[(anchorAl1-1)*2+1]+m2BS[(anchorAl2-1)*2+0]+m2BS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1], 
		      m1BS[(anchorAl2-1)*2+0]+m1BS[(anchorAl2-1)*2+1],
		      N
		      );
  double fMSR = qcor( m1BS[(anchorAl1-1)*2+0]+m1BS[(anchorAl1-1)*2+1]+m1BS[(anchorAl2-1)*2+0]+m1BS[(anchorAl2-1)*2+1], 
		      m2BS[(anchorAl1-1)*2+0]+m2BS[(anchorAl1-1)*2+1]+m2BS[(anchorAl2-1)*2+0]+m2BS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl1-1)*2+1]+oBS[(anchorAl2-1)*2+1], 
		      oBS[(anchorAl1-1)*2+1]+oBS[(anchorAl2-1)*2+1], 
		      m1BS[(anchorAl1-1)*2+1]+m1BS[(anchorAl2-1)*2+1],
		      N
		      );
  double fMBZ = fMBR * sqrtN;
  */

  int oOTR = oBS[(anchorO1-1)*2+0]+oBS[(anchorO1-1)*2+1]+oBS[(anchorO2-1)*2+0]+oBS[(anchorO2-1)*2+1];
  double eOTR = eBS[(anchorO1-1)*2+0]+eBS[(anchorO1-1)*2+1]+eBS[(anchorO2-1)*2+0]+eBS[(anchorO2-1)*2+1];
  double fIOR = oOTR/eOTR;
  double fIOZ = (oOTR-eOTR)/sqrt(ve*2+ZEPS);
  double fAOZ = (oOTR - 2*(oBS[(anchorAl2-1)*2+0]+oBS[(anchorAl2-1)*2+1]))/sqrt(ve*6 + ZEPS);
  double fAOI = fIOZ + fAOZ;
  double fMQ0 = mHist[0]/(N+ZEPS);
  double fMQ10 = fMQ0;
  double mMQ = 0;
  for(int i=0; i < 256; ++i) mMQ += (mHist[i]/(N+ZEPS) * i);
  for(int i=1; i < 10; ++i) fMQ10 += (mHist[i]/(N+ZEPS));
  double fMQ20 = fMQ10;
  for(int i=10; i < 20; ++i) fMQ20 += (mHist[i]/(N+ZEPS));
  double fMQ30 = fMQ20;
  for(int i=20; i < 30; ++i) fMQ30 += (mHist[i]/(N+ZEPS));
  double fABE = (rHET+ZEPS) / (oHET+ZEPS+ZEPS);
  double fABZ = (2.*rHET-oHET) / sqrt(vHET+ZEPS);

  //fprintf(stderr,"%f %f %f %f\n",rHET,oHET,vHET,eHET);
  //abort();
  //double fIOH = (oHET+ZEPS) / (eHET+ZEPS);
  //double fIOD = (fIOH-oOTR/(double)N);
  //double fBCS = 2*(llkNull-llkSNP);
  double fFIC = 1.-oHET/eHET;
  //double fFIC = 1-eHET/(int)pPileVcfs.size()/2./anchorAF/(1.-anchorAF);
  //double fFIC = 1-eHET/(int)pPileVcfs.size()/(2.*anchorAF*(1.-anchorAF)+1e-5);
  if ( fFIC < -1 ) fFIC = -1;
  double fLQR = Nl/(N+Nl+ZEPS);

  std::vector<std::string> keys;
  std::vector<double> values;
  
  keys.push_back("STR"); values.push_back(fSTR);
  keys.push_back("STZ"); values.push_back(fSTZ);
  keys.push_back("CBR"); values.push_back(fCBR);
  keys.push_back("CBZ"); values.push_back(fCBZ);
  //keys.push_back("QBR"); values.push_back(fQBR);
  //keys.push_back("QBZ"); values.push_back(fQBZ);
  //keys.push_back("MBR"); values.push_back(fMBR);
  //keys.push_back("MSR"); values.push_back(fMSR);
  //keys.push_back("MBZ"); values.push_back(fMBZ);
  keys.push_back("IOR"); values.push_back(fIOR);
  keys.push_back("IOZ"); values.push_back(fIOZ);
  //keys.push_back("IOH"); values.push_back(fIOH);
  //keys.push_back("IOD"); values.push_back(fIOD);
  keys.push_back("AOI"); values.push_back(fAOI);
  keys.push_back("AOZ"); values.push_back(fAOZ);
  //keys.push_back("ABE"); values.push_back(fABE);
  //keys.push_back("ABZ"); values.push_back(fABZ);
  //keys.push_back("BCS"); values.push_back(fBCS);
  //keys.push_back("FIC"); values.push_back(fFIC);
  keys.push_back("LQR"); values.push_back(fLQR);
  keys.push_back("MQ0"); values.push_back(fMQ0);
  keys.push_back("MQ10"); values.push_back(fMQ10);
  keys.push_back("MQ20"); values.push_back(fMQ20);
  keys.push_back("MQ30"); values.push_back(fMQ30);
  //keys.push_back("MMQ"); values.push_back(mMQ);

  String str;

  pMarker->asInfoKeys.Add("LBS");
  str.printf("%d",lBS[0]);
  for(int i=1; i < 8; ++i) {
    str.catprintf(",%d",lBS[i]);
  }
  pMarker->asInfoValues.Add(str.c_str());

  pMarker->asInfoKeys.Add("OBS");
  str.printf("%d",oBS[0]);
  for(int i=1; i < 8; ++i) {
    str.catprintf(",%d",oBS[i]);
  }
  pMarker->asInfoValues.Add(str.c_str());

  for(int i=0; i < (int)keys.size(); ++i) {
    pMarker->asInfoKeys.Add(keys[i].c_str());
    str.printf("%.3lf",values[i]);
    pMarker->asInfoValues.Add(str.c_str());
  }

  //pMarker->asInfoKeys.Add("EMAF");
  //str.printf("%.6lf",emAF);
  //pMarker->asInfoValues.Add(str.c_str());

  //pMarker->asInfoKeys.Add("OFN");
  //str.printf("%d",nDupAlts);
  //pMarker->asInfoValues.Add(str.c_str());

  //pMarker->asInfoKeys.Add("OFQ");
  //str.printf("%d",qDupAlts);
  //pMarker->asInfoValues.Add(str.c_str());

  //pMarker->asInfoKeys.Add("UFN");
  //str.printf("%d",nNonDupAlts);
  //pMarker->asInfoValues.Add(str.c_str());

  //pMarker->asInfoKeys.Add("OFD");
  //str.printf("%d",nDupAlts-anchorAC);
  //pMarker->asInfoValues.Add(str.c_str());

  pMarker->printVCFMarker(oFile,false);

  delete [] lBS;
  delete [] oBS;
  delete [] eBS;
  //delete [] q1BS;
  //delete [] q2BS;
  //delete [] m1BS;
  //delete [] m2BS;
  delete [] c1BS;
  delete [] c2BS;
  delete [] mHist;
  //delete [] hashes;
}

/*
void VariantStatizer::writeCurrentMarker(IFILE oFile) {
  VcfMarker* pMarker = anchorVcf.getLastMarker();

  // basic read summary statistics
  // bS : [A,C,G,T] * [F,B] observed counts at bq >= 13

  // calculate statistics
  // STR : r2(#RF,#RB,#AF,#AB)
  // STZ : z(#RF,#RB,#AF,#AB)
  // CBR : r2(#RC,#AC)
  // CSR : r2(#FC,#BC)
  // ABE : Expected allele balance : \sum Pr(Het|Data)E[refBase]

  // individual summary statistics
  // GLs : Pr(Data|RR,RA,AA)

  // basic numbers we have
  // cnts : base * strand - (A,C,G,T) * (F,B) observed counts at bq >= 13
  // nullR, nullO     : # of expREF and # of expOthers under null hypothesis
  // altR, altA, altO : # of expREF/expALT/expOTR under alternative hypothesis with the allele frequency estimates
  // nullLLK : Likelihood under the null
  // altLLK  : Likelihood under the alt
  // infNR : inflation of nonREF bases compared to expectation
  // nulladjLLK : Likelihood of data under the adjusted null
  // altadjLLK  : Likelihood of data under the adjusted alt
  int* cnts = new int[14]();
  int sumC = 0, sqC = 0, sumCS = 0, sumCA = 0, nOTR = 0, nALT = 0;
  double nullREF = 0, nullALT = 0, nullOTR = 0, altREF = 0, altALT = 0, altOTR = 0, varExp = 0;
  int MQcnts[5] = {0,0,0,0,0}; // MQ0, MQ<10, MQ<20, MQ<30, MQ>=30
  double llkSNP = 0;
  double llkNull = 0;
  double baseProbs[5] = {0,0,0,0,0};

  // first pass, calculate expectations
  int b, s, m, q, c;
  double e, cm, ch, t;
  double logThird = 0-log10(3);
  double pHet = 0;
  for(int i=0; i < (int)pPileVcfs.size(); ++i) {
    double GLs[3] = {0,0,0};
    for(int j=0; j < nReads[i]; ++j) {
      b = pcBases[i][j];
      s = pcStrands[i][j];
      m = pcMapQs[i][j];
      q = pcQuals[i][j];
      c = pcCycles[i][j];
      e = vPhred2Err[q];
      cm = vPhred2Match[q];
      ch = vPhred2Het[q];

      ++cnts[b*2+s];
      if ((b > 0 ) && ( b < 5 )){
	if ( m >= 30 ) ++MQcnts[4];
	else if ( m >= 20 ) ++MQcnts[3];
	else if ( m >= 10 ) ++MQcnts[2];
	else if ( m > 0 ) ++MQcnts[1];
	else ++MQcnts[0];

	if ( q > 5 ) {
	  nullREF += (1.-e);
	  nullALT += e/3.;
	  nullOTR += e*2./3.;
	  altOTR += e*2./3.;
	  altREF += ( (1.-anchorAF)*(1.-e)+anchorAF*e/3 );
	  altALT += ( (anchorAF)*(1.-e)+(1.-anchorAF)*e/3 );
	  varExp += (e/3.0*(1.-e/3.));

	  for(int k=1; k < 5; ++k) {
	    if ( b == k ) {
	      baseProbs[k] += (1.-e);
	    }
	    else {
	      baseProbs[k] += e/3.;
	    }
	  }
	}
	// expected variance of variant count
      }

      if ( b == anchorAl1 ) {
	sumC += c;
	sqC += c*c;
	sumCS += c*s;
	if ( q > 5 ) {
	  GLs[0] += cm;
	  GLs[1] += ch;
	  GLs[2] += (-0.1*q+logThird);
	}
      }
      else if ( b == anchorAl2 ) {
	sumC += c;
	sqC += c*c;
	sumCS += c*s;
	sumCA += c;
	if ( q > 5 ) {
	  ++nALT;
	  GLs[0] += (-0.1*q+logThird);
	  GLs[1] += ch;
	  GLs[2] += cm;
	}
      }
      else if ( b < 5 ) { // A,C,G,T
	if ( q > 5 ) {
	  ++nOTR;
	  GLs[0] += (-0.1*q+logThird);
	  GLs[1] += (-0.1*q+logThird);
	  GLs[2] += (-0.1*q+logThird);
	}
      }
    }

    // calculate llkSNP
    if ( GLs[0] > GLs[1] ) {
      if ( GLs[0] > GLs[2] ) { // GLs[0] is the largest
	t = (1.-anchorAF)*(1.-anchorAF) + 2.*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[0]) + anchorAF*anchorAF*pow(10.,GLs[2]-GLs[0]);
	llkSNP += (GLs[0] + log10(t));
	//if ( t == 0 ) fprintf(stderr,"1 t=%lf\n",t)
	pHet += (2*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[0])/t);
      }
      else { // GLs[2] is the largest
	t = (1.-anchorAF)*(1.-anchorAF)*pow(10.,GLs[0]-GLs[2]) + 2.*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2]) + anchorAF*anchorAF;
	llkSNP += (GLs[2] + log10(t));
	//if ( t == 0 ) fprintf(stderr,"2 t=%lf\n",t)
	pHet += (2*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2])/t);	
      }
    }
    else {
      if ( GLs[1] > GLs[2] ) { // GLs[1] is the largest
	t = (1.-anchorAF)*(1.-anchorAF)*pow(10.,GLs[0]-GLs[1]) + 2.*anchorAF*(1.-anchorAF) + anchorAF*anchorAF*pow(10.,GLs[2]-GLs[1]);
	llkSNP += (GLs[1] + log10(t));
	//if ( t == 0 ) fprintf(stderr,"3 t=%lf\n",t)
	pHet += (2*anchorAF*(1.-anchorAF)/t);
      }
      else { // GLs[2] is the largest
	t = (1.-anchorAF)*(1.-anchorAF)*pow(10.,GLs[0]-GLs[2]) + 2.*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2]) + anchorAF*anchorAF;
	llkSNP += (GLs[2] + log10(t));
	//if ( t == 0 ) fprintf(stderr,"4 t=%lf\n",t)
	pHet += (2*anchorAF*(1.-anchorAF)*pow(10.,GLs[1]-GLs[2])/t);	
      }
    }
  }

  double sumBaseProbs = baseProbs[1] + baseProbs[2] + baseProbs[3] + baseProbs[4];
  baseProbs[1] /= sumBaseProbs;
  baseProbs[2] /= sumBaseProbs;
  baseProbs[3] /= sumBaseProbs;
  baseProbs[4] /= sumBaseProbs;
  //baseProbs[0] = baseProbs[1] = baseProbs[2] = baseProbs[3] = baseProbs[4] = 0;
  //baseProbs[anchorAl1] = (1.-anchorAF);
  //baseProbs[anchorAl2] = anchorAF;

  double lkNullBase, lkNullBulk;
  for(int i=0; i < (int)pPileVcfs.size(); ++i) {
    lkNullBulk = 1.;
    for(int j=0; j < nReads[i]; ++j) {
      b = pcBases[i][j];
      q = pcQuals[i][j];
      e = vPhred2Err[q];
      if ( q > 5 ) {
	lkNullBase = 0;
	for(int k=1; k < 5; ++k) {
	  if ( b == k ) {
	    lkNullBase += (baseProbs[k] * (1.-e));
	  }
	  else {
	    lkNullBase += (baseProbs[k] * e/3.);
	  }
	}
	if ( lkNullBulk < 1e-100 ) {
	  llkNull += log10(lkNullBulk);
	  lkNullBulk = 1.;
	}
	lkNullBulk *= lkNullBase;
      }
    }
    llkNull += log10(lkNullBulk);
  }

  int nRF = cnts[anchorAl1*2];
  int nRB = cnts[anchorAl1*2+1];
  int nAF = cnts[anchorAl2*2];
  int nAB = cnts[anchorAl2*2+1];

  int nR = nRF+nRB;
  int nA = nAF+nAB;
  int nF = nRF+nAF;
  int nB = nRB+nAB;

  double sdC = sqrt((double)sqC*(double)(nR+nA) - (double)((sumC*sumC)));
  double sdA = sqrt((double)(nA+nR)*nA-(double)nA*nA);
  double sdB = sqrt((double)(nF+nB)*nB-(double)nB*nB);

  //String STC;
  String STR, STZ, CBR, CBZ, CSR, IOZ, IOR, AOZ, AOI, BCS, FIC;
  if ( ( nR < 5 ) || ( nA < 5 ) ) {
    STR = "0";
    STZ = "0";
    CBR = "0";
    CBZ = "0";
  }
  else {
    double fSTR = ((nRF+.5)*(nAB+.5)-(nRB+.5)*(nAF+.5))/sqrt((nR+1.)*(nA+1.)*(nF+1.)*(nB+1.));
    double fCBR = ((double)(sumCA*(nR+nA))-(double)(sumC*nA))/(sdC+0.01)/(sdA+.01);
    //STC.printf("%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",cnts[2],cnts[3],cnts[4],cnts[5],cnts[6],cnts[8],cnts[9],cnts[10],cnts[11],cnts[12],cnts[13]);
    STR.printf("%.3lf",fSTR);
    STZ.printf("%.3lf",(double)sqrt(nR+nA)*fSTR);
    CBR.printf("%.3lf",fCBR);
    CBZ.printf("%.3lf",(double)sqrt(nR+nA)*fCBR);
  }

  String MQ0, MQ10, MQ20, MQ30;
  int totMQcnts = MQcnts[0]+MQcnts[1]+MQcnts[2]+MQcnts[3]+MQcnts[4];
  MQ0.printf("%.3lf",MQcnts[0]/(totMQcnts+1e-6));
  MQ10.printf("%.3lf",(MQcnts[0]+MQcnts[1])/(totMQcnts+1e-6));
  MQ20.printf("%.3lf",(MQcnts[0]+MQcnts[1]+MQcnts[2])/(totMQcnts+1e-6));
  MQ30.printf("%.3lf",(MQcnts[0]+MQcnts[1]+MQcnts[2]+MQcnts[3])/(totMQcnts+1e-6));

  if ( ( nF < 5 ) || ( nB < 5 ) ) {
    CSR = "0";
  }
  else {
    CSR.printf("%.3lf",((double)(sumCS*(nF+nB))-(double)(sumC*nB))/(sdC+0.01)/(sdB+0.01));
  }

  IOZ.printf("%.3lf",(nOTR-nullOTR)/sqrt(varExp*2+1e-6));
  IOR.printf("%.1lf",nOTR/(nullOTR+1e-4)+.05);
  AOZ.printf("%.1lf",(nOTR-2.*nALT)/sqrt(varExp*6+1e-6));
  AOI.printf("%.1lf",IOZ.AsDouble()+AOZ.AsDouble());
  BCS.printf("%.1lf",2*(llkNull-llkSNP));
  double dFST = 1.-pHet/(int)pPileVcfs.size()/2./anchorAF/(1.-anchorAF);
  if ( dFST < -1 ) { dFST = -1.; }
  FST.printf("%.3lf",dFST);
  
  //pMarker->asInfoKeys.Add("STC");
  //pMarker->asInfoValues.Add(STC);
  pMarker->asInfoKeys.Add("STR");
  pMarker->asInfoValues.Add(STR);
  pMarker->asInfoKeys.Add("STZ");
  pMarker->asInfoValues.Add(STZ);
  pMarker->asInfoKeys.Add("CBR");
  pMarker->asInfoValues.Add(CBR);
  pMarker->asInfoKeys.Add("CBZ");
  pMarker->asInfoValues.Add(CBZ);
  pMarker->asInfoKeys.Add("CSR");
  pMarker->asInfoValues.Add(CSR);
  pMarker->asInfoKeys.Add("IOZ");
  pMarker->asInfoValues.Add(IOZ);
  pMarker->asInfoKeys.Add("IOR");
  pMarker->asInfoValues.Add(IOR);
  pMarker->asInfoKeys.Add("AOZ");
  pMarker->asInfoValues.Add(AOZ);
  pMarker->asInfoKeys.Add("AOI");
  pMarker->asInfoValues.Add(AOI);
  pMarker->asInfoKeys.Add("BCS");
  pMarker->asInfoValues.Add(BCS);
  pMarker->asInfoKeys.Add("FST");
  pMarker->asInfoValues.Add(FST);
  pMarker->asInfoKeys.Add("MQ0");
  pMarker->asInfoValues.Add(MQ0);
  pMarker->asInfoKeys.Add("MQ10");
  pMarker->asInfoValues.Add(MQ10);
  pMarker->asInfoKeys.Add("MQ20");
  pMarker->asInfoValues.Add(MQ20);
  pMarker->asInfoKeys.Add("MQ30");
  pMarker->asInfoValues.Add(MQ30);

  pMarker->printVCFMarker(oFile,false);
  
  //ifprintf(oFile,"\n");

  delete[] cnts;
}
*/
