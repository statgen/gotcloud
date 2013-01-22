#include <math.h>
//#include <boost/thread/mutex.hpp>

#include "VcfFile.h"
#include "VariantStatizer.h"
#include "Logger.h"

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
  char* pcBase = new char[MAX_READS_PER_BASE];
  char* pcMapQ = new char[MAX_READS_PER_BASE];
  char* pcQual = new char[MAX_READS_PER_BASE];
  char* pcStrand = new char[MAX_READS_PER_BASE];
  short* pcCycle = new short[MAX_READS_PER_BASE];

  pPileVcfs.push_back(pVcf);
  nReads.push_back(0);
  pcBases.push_back(pcBase);
  pcMapQs.push_back(pcMapQ);
  pcQuals.push_back(pcQual);
  pcStrands.push_back(pcStrand);
  pcCycles.push_back(pcCycle);

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
	char cBase = vBase2Num[(int)tok[l][0]];
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
	pcMapQs[index][l] = (char)(tok[l].AsInteger());
      }
    }    
    else if ( pMarker->asFormatKeys[k].Compare("BASEQ") == 0 ) {
      tok.ReplaceColumns(pMarker->asSampleValues[k],',');
      if ( ( tok.Length() != nReads[index] ) && ( nReads[index] < MAX_READS_PER_BASE) ) {
	Logger::gLogger->error("# of BASEQ does not match to N at %s:%d",pMarker->sChrom.c_str(),pMarker->nPos);
      }
      for(int l=0; (l < nReads[index]) && (l < MAX_READS_PER_BASE); ++l) {
	pcQuals[index][l] = (char)(tok[l].AsInteger());
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
	pcCycles[index][l] = (short)(tok[l].AsInteger());
      }
    }
  }
  return true;
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

    if ( anchorAF < 0 ) {
      Logger::gLogger->warning("Cannot find AF in the INFO field at the first marker");
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

void VariantStatizer::writeCurrentMarker(IFILE oFile) {
  VcfMarker* pMarker = anchorVcf.getLastMarker();

  // caculate statistics
  // STR : r2(#RF,#RB,#AF,#AB)
  // STZ : z(#RF,#RB,#AF,#AB)
  // CBR : r2(#RC,#AC)
  // CSR : r2(#FC,#BC)
  // ENZ :

  // basic numbers we have
  // cnts : (0,A,C,G,T,N,D) * (F,B) observed counts
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

  // first pass, calculate expectations
  for(int i=0; i < (int)pPileVcfs.size(); ++i) {
    for(int j=0; j < nReads[i]; ++j) {
      ++cnts[pcBases[i][j]*2+pcStrands[i][j]];
      if ( pcBases[i][j] < 5 ) { // A,C,G,T bases
	if ( pcMapQs[i][j] >= 30 ) {
	  ++MQcnts[4];
	}
	else if ( pcMapQs[i][j] >= 20 ) {
	  ++MQcnts[3];
	}
	else if ( pcMapQs[i][j] >= 10 ) {
	  ++MQcnts[2];
	}
	else if ( pcMapQs[i][j] > 0 ) {
	  ++MQcnts[1];
	}
	else {
	  ++MQcnts[0];
	}

	if ( pcQuals[i][j] > 5 ) {
	  double e = vPhred2Err[pcQuals[i][j]];
	  nullREF += (1.-e);
	  nullALT += e/3.;
	  nullOTR += e*2./3.;
	  altOTR += e*2./3.;
	  altREF += ( (1.-anchorAF)*(1.-e)+anchorAF*e/3 );
	  altALT += ( (anchorAF)*(1.-e)+(1.-anchorAF)*e/3 );
	  varExp += (e/3.0*(1.-e/3.));
	}
	// expected variance of variant count
      }

      if ( pcBases[i][j] == anchorAl1 ) {
	sumC += pcCycles[i][j];
	sqC += (pcCycles[i][j]*pcCycles[i][j]);
	sumCS += (pcCycles[i][j]*pcStrands[i][j]);
      }
      else if ( pcBases[i][j] == anchorAl2 ) {
	sumC += pcCycles[i][j];
	sqC += (pcCycles[i][j]*pcCycles[i][j]);
	sumCS += (pcCycles[i][j]*pcStrands[i][j]);
	sumCA += pcCycles[i][j];
	if ( pcQuals[i][j] > 5 ) {
	  ++nALT;
	}
      }
      else if ( pcBases[i][j] < 5 ) { // A,C,G,T
	if ( pcQuals[i][j] > 5 ) {
	  ++nOTR;
	}
      }
    }
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
  String STR, STZ, CBR, CBZ, CSR, IOZ, IOR, AOZ, AOI;
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
