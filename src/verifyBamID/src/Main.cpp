/*
 *  Copyright (C) 2010  Regents of the University of Michigan
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <values.h>
#include <math.h>
#include <string>

#include "Generic.h"
#include "SamFile.h"
#include "Logger.h"
#include "BgzfFileType.h"
#include "VerifyBamID.h"
#include "VerifyBamIDArgs.h"
#include "BamPileBases.h"
#include "Parameters.h"
#include "Error.h"
#include "MathGenMin.h"

#define MAX_Q 100 // maximum baseQuality phred score

Logger* Logger::gLogger = NULL; // Message log 

// main function of verifyBamID
int main(int argc, char** argv) {
  printf("verifyBamID 1.0.0 -- verify identity and purity of sequence data\n"
	 "(c) 2010 Hyun Min Kang, Goo Jun, and Goncalo Abecasis\n\n");

  VerifyBamIDArgs args;
  ParameterList pl;

  BEGIN_LONG_PARAMETERS(longParameters)
    LONG_PARAMETER_GROUP("Input Files")
    LONG_STRINGPARAMETER("vcf",&args.sVcfFile)
    LONG_STRINGPARAMETER("bam",&args.sBamFile)
    LONG_STRINGPARAMETER("subset",&args.sSubsetInds)
    LONG_STRINGPARAMETER("smID",&args.sSMID)

    LONG_PARAMETER_GROUP("VCF analysis options")
    LONG_DOUBLEPARAMETER("genoError",&args.genoError)
    LONG_DOUBLEPARAMETER("minAF",&args.minAF)
    LONG_DOUBLEPARAMETER("minCallRate",&args.minCallRate)

    LONG_PARAMETER_GROUP("Individuals to compare with chip data")
    EXCLUSIVE_PARAMETER("site",&args.bSiteOnly)
    EXCLUSIVE_PARAMETER("self",&args.bSelfOnly)
    EXCLUSIVE_PARAMETER("best",&args.bFindBest)

    LONG_PARAMETER_GROUP("Chip-free optimization options")
    EXCLUSIVE_PARAMETER("free-none",&args.bFreeNone)
    EXCLUSIVE_PARAMETER("free-mix",&args.bFreeMixOnly)
    EXCLUSIVE_PARAMETER("free-refBias",&args.bFreeRefBiasOnly)
    EXCLUSIVE_PARAMETER("free-full",&args.bFreeFull)

    LONG_PARAMETER_GROUP("With-chip optimization options")
    EXCLUSIVE_PARAMETER("chip-none",&args.bChipNone)
    EXCLUSIVE_PARAMETER("chip-mix",&args.bChipMixOnly)
    EXCLUSIVE_PARAMETER("chip-refBias",&args.bChipRefBiasOnly)
    EXCLUSIVE_PARAMETER("chip-full",&args.bChipFull)

    LONG_PARAMETER_GROUP("BAM analysis options")
    LONG_PARAMETER("ignoreRG",&args.bIgnoreRG)
    LONG_PARAMETER("ignoreOverlapPair",&args.bIgnoreOverlapPair)
    LONG_PARAMETER("noEOF",&args.bNoEOF)
    LONG_PARAMETER("precise",&args.bPrecise)
    LONG_INTPARAMETER("minMapQ",&args.minMapQ)
    LONG_INTPARAMETER("maxDepth",&args.maxDepth)
    LONG_INTPARAMETER("minQ",&args.minQ)
    LONG_INTPARAMETER("maxQ",&args.maxQ)
    LONG_DOUBLEPARAMETER("grid",&args.grid)

    LONG_PARAMETER_GROUP("Modeling Reference Bias")
    LONG_DOUBLEPARAMETER("refRef",&args.pRefRef)
    LONG_DOUBLEPARAMETER("refHet",&args.pRefHet)
    LONG_DOUBLEPARAMETER("refAlt",&args.pRefAlt)

    LONG_PARAMETER_GROUP("Output options")
    LONG_STRINGPARAMETER("out",&args.sOutFile)
    LONG_PARAMETER("verbose",&args.bVerbose)
  END_LONG_PARAMETERS();

  pl.Add(new LongParameters("Available Options",longParameters));
  pl.Read(argc, argv);
  pl.Status();

  // check the validity of input files
  if ( args.sVcfFile.IsEmpty() ) {
    error("--vcf [vcf file] required");
  }

  if ( args.sBamFile.IsEmpty() ) {
    error("--bam [bam file] is required");
  }

  if ( args.sOutFile.IsEmpty() ) {
    error("--out [output prefix] is required");
  }
  Logger::gLogger = new Logger((args.sOutFile + ".log").c_str(), args.bVerbose);

  if ( ! ( args.bSiteOnly || args.bSelfOnly || args.bFindBest ) ) {
    warning("--self option was autotomatically turned on by default. Specify --best option if you wanted to check across all possible samples in the VCF");
    args.bSelfOnly = true;
  }

  if ( ( args.maxDepth > 20 ) && ( !args.bPrecise ) ) {
    warning("--precise option is not turned on at --maxDepth %d : may be prone to precision errors",args.maxDepth);
  }

  if ( ( args.bChipRefBiasOnly ) && ( !args.bSelfOnly ) ) {
    error("--self must be set for --chip-refBias to work. Skipping..");
  }

  // check timestamp
  time_t t;
  time(&t);
  Logger::gLogger->writeLog("Analysis started on %s",ctime(&t));

  // load arguments
  VerifyBamID vbid(&args);

  // load input VCF and BAM files
  Logger::gLogger->writeLog("Opening Input Files");
  vbid.loadFiles(args.sBamFile.c_str(), args.sVcfFile.c_str());

  // Check which genotype-free method is used
  if ( args.bFreeNone ) {  // if no genotype-free mode is tested. skip it
    // do nothing for genotype-free estimation
    Logger::gLogger->writeLog("Skipping chip-free estimation of sample mixture");
  }
  else if ( args.bFreeMixOnly ) { // only mixture is estimated.
    // genotype-free method
    Logger::gLogger->writeLog("Performing chip-free estimation of sample mixture at fixed reference bias parameters (%lf, %lf, %lf)",args.pRefRef,args.pRefHet,args.pRefAlt);

    // scan across multiple readgroups
    for(int rg=-1; rg < vbid.nRGs - (int)args.bIgnoreRG; ++rg) {
      VerifyBamID::mixLLK mix(&vbid);
      mix.OptimizeLLK(rg);
      Logger::gLogger->writeLog("Optimal per-sample fMix = %lf, LLK0 = %lf, LLK1 = %lf\n",mix.fMix,mix.llk0,mix.llk1);
      vbid.mixOut.llk0s[rg+1] = mix.llk0;
      vbid.mixOut.llk1s[rg+1] = mix.llk1;
      vbid.mixOut.fMixs[rg+1] = mix.fMix;
    }

    //vbid.mixRefHet = 0.5;
    //vbid.mixRefAlt = 0.00;
  }
  else if ( args.bFreeRefBiasOnly ) {
    Logger::gLogger->writeLog("Performing chip-free estimation of reference-bias without sample mixture");
    for(int rg=-1; rg < vbid.nRGs - (int)args.bIgnoreRG; ++rg) {
      VerifyBamID::refBiasMixLLKFunc myFunc(&vbid, rg);
      AmoebaMinimizer myMinimizer;
      Vector startingPoint(2);
      startingPoint[0] = 0;      // pRefHet = 0.5
      startingPoint[1] = -4.595; // pRefAlt = 0.01
      myMinimizer.func = &myFunc;
      myMinimizer.Reset(2);
      myMinimizer.point = startingPoint;
      myMinimizer.Minimize(1e-6);
      double pRefHet = VerifyBamID::invLogit(myMinimizer.point[0]);
      double pRefAlt = VerifyBamID::invLogit(myMinimizer.point[1]);
      Logger::gLogger->writeLog("Reference Bias Estimated as ( Pr[refBase|HET] = %lf, Pr[refBase|ALT] = %lf) with LLK = %lf at readGroup %d",pRefHet,pRefAlt,myMinimizer.fmin,rg);
      //vbid.setRefBiasParams(1.0, pRefHet, pRefAlt);

      vbid.mixOut.llk0s[rg+1] = myFunc.llk0;
      vbid.mixOut.llk1s[rg+1] = myFunc.llk1;
      vbid.mixOut.refHets[rg+1] = myFunc.pRefHet;
      vbid.mixOut.refAlts[rg+1] = myFunc.pRefAlt;
    }
  }
  else if ( args.bFreeFull ) {
    Logger::gLogger->writeLog("Performing chip-free estimation of reference-bias and sample mixture together");
    for(int rg = -1; rg < vbid.nRGs - args.bIgnoreRG; ++rg) {
      VerifyBamID::fullMixLLKFunc myFunc(&vbid, rg);
      AmoebaMinimizer myMinimizer;
      Vector startingPoint(3);
      startingPoint[0] = -3.91;  // start with fMix = 0.01
      startingPoint[1] = 0;      // pRefHet = 0.5
      startingPoint[2] = -4.595; // pRefAlt = 0.01
      myMinimizer.func = &myFunc;
      myMinimizer.Reset(3);
      myMinimizer.point = startingPoint;
      myMinimizer.Minimize(1e-6);
      double fMix = VerifyBamID::invLogit(myMinimizer.point[0]);
      if ( fMix > 0.5 ) 
	fMix = 1.-fMix;
      double pRefHet = VerifyBamID::invLogit(myMinimizer.point[1]);
      double pRefAlt = VerifyBamID::invLogit(myMinimizer.point[2]);
      Logger::gLogger->writeLog("Optimal per-sample fMix = %lf\n",fMix);
      Logger::gLogger->writeLog("Reference Bias Estimated as ( Pr[refBase|HET] = %lf, Pr[refBase|ALT] = %lf) with LLK = %lf",pRefHet,pRefAlt,myMinimizer.fmin);
      //vbid.setRefBiasParams(1.0, pRefHet, pRefAlt);

      vbid.mixOut.llk0s[rg+1] = myFunc.llk0;
      vbid.mixOut.llk1s[rg+1] = myFunc.llk1;
      vbid.mixOut.fMixs[rg+1] = myFunc.fMix;
      vbid.mixOut.refHets[rg+1] = myFunc.pRefHet;
      vbid.mixOut.refAlts[rg+1] = myFunc.pRefAlt;
    }
  }
  Logger::gLogger->writeLog("calculating depth distribution");  
  vbid.calculateDepthDistribution(args.maxDepth, vbid.mixOut);

  Logger::gLogger->writeLog("finished calculating depth distribution");  

  std::vector<int> bestInds(vbid.nRGs+1,-1);
  std::vector<int> selfInds(vbid.nRGs+1,-1);

  if ( args.bChipNone ) {
    // do nothing
    Logger::gLogger->writeLog("Skipping with-chip estimation of sample mixture");
  }
  else if ( args.bChipMixOnly ) {
    Logger::gLogger->writeLog("Performing with-chip estimation of sample mixture at fixed reference bias parameter (%lf, %lf, %lf)",args.pRefRef,args.pRefHet,args.pRefAlt);
    
    for(int rg=-1; rg < (vbid.nRGs - (int)args.bIgnoreRG); ++rg) {
      double maxIBD = -1;
      VerifyBamID::ibdLLK ibd(&vbid);
      for(int i=0; i < (int)vbid.pGenotypes->indids.size(); ++i) {
	double fIBD = ibd.OptimizeLLK(i, rg);
	Logger::gLogger->writeLog("Comparing with individual %s.. Optimal fIBD = %lf, LLK0 = %lf, LLK1 = %lf for readgroup %d",vbid.pGenotypes->indids[i].c_str(),fIBD, ibd.llk0, ibd.llk1, rg);
	if ( maxIBD < fIBD ) {
	  bestInds[rg+1] = i;
	  vbid.bestOut.llk0s[rg+1] = ibd.llk0;
	  vbid.bestOut.llk1s[rg+1] = ibd.llk1;
	  vbid.bestOut.fMixs[rg+1] = 1-ibd.fIBD;
	  maxIBD = ibd.fIBD;
	}

	if ( ( (rg < 0) && (vbid.pPile->sBamSMID == vbid.pGenotypes->indids[i] ) ) || ( ( rg >= 0 ) && ( vbid.pPile->vsSMIDs[rg] == vbid.pGenotypes->indids[i]) ) ) {
	  selfInds[rg+1] = i;
	  vbid.selfOut.llk0s[rg+1] = ibd.llk0;
	  vbid.selfOut.llk1s[rg+1] = ibd.llk1;
	  vbid.selfOut.fMixs[rg+1] = 1-ibd.fIBD;
	}
      }

      if ( bestInds[rg+1] >= 0 ) {
	Logger::gLogger->writeLog("Best Matching Individual is %s with IBD = %lf",vbid.pGenotypes->indids[bestInds[rg+1]].c_str(),maxIBD);
	vbid.calculateDepthByGenotype(bestInds[rg+1],rg,vbid.bestOut);
      }

      if ( selfInds[rg+1] >= 0 ) {
	Logger::gLogger->writeLog("Self Individual is %s with IBD = %lf",vbid.pGenotypes->indids[selfInds[rg+1]].c_str(),vbid.selfOut.fMixs[rg+1]);
	vbid.calculateDepthByGenotype(selfInds[rg+1],rg,vbid.selfOut);
      }
    }
  }
  else if ( args.bChipRefBiasOnly ) {
    Logger::gLogger->writeLog("Performing with-chip estimation of reference-bias without sample mixture");
    if ( args.bSelfOnly ) {
      for(int rg=-1; rg < (vbid.nRGs - (int)args.bIgnoreRG); ++rg) {
	VerifyBamID::refBiasIbdLLKFunc myFunc(&vbid, rg);
	AmoebaMinimizer myMinimizer;
	Vector startingPoint(2);
	startingPoint[0] = 0;      // pRefHet = 0.5
	startingPoint[1] = -4.595; // pRefAlt = 0.01
	myMinimizer.func = &myFunc;
	myMinimizer.Reset(2);
	myMinimizer.point = startingPoint;
	myMinimizer.Minimize(1e-6);
	double pRefHet = VerifyBamID::invLogit(myMinimizer.point[0]);
	double pRefAlt = VerifyBamID::invLogit(myMinimizer.point[1]);
	Logger::gLogger->writeLog("Reference Bias Estimated as ( Pr[refBase|HET] = %lf, Pr[refBase|ALT] = %lf) with LLK = %lf",pRefHet,pRefAlt,myMinimizer.fmin);
	//vbid.setRefBiasParams(1.0, pRefHet, pRefAlt);

	vbid.selfOut.llk0s[rg+1] = myFunc.llk0;
	vbid.selfOut.llk1s[rg+1] = myFunc.llk1;
	vbid.selfOut.refHets[rg+1] = myFunc.pRefHet;
	vbid.selfOut.refAlts[rg+1] = myFunc.pRefAlt;
	vbid.calculateDepthByGenotype(0,rg,vbid.selfOut);
      }
    }
    else {
      Logger::gLogger->warning("--self must be set for --chip-refBias to work. Skipping..");
    }
  }
  else if ( args.bChipFull ) {
    Logger::gLogger->writeLog("Performing with-chip estimation of reference-bias and sample mixture together");
    for(int rg=-1; rg < (vbid.nRGs - (int)args.bIgnoreRG); ++rg) {
      double maxIBD = -1;

      for(int i=0; i < (int)vbid.pGenotypes->indids.size(); ++i) {
	VerifyBamID::fullIbdLLKFunc myFunc(&vbid,i,rg);
	AmoebaMinimizer myMinimizer;
	Vector startingPoint(3);
	startingPoint[0] = 3.91;  // start with fIBD = 0.99
	startingPoint[1] = 0;      // pRefHet = 0.5
	startingPoint[2] = -4.595; // pRefAlt = 0.01
	myMinimizer.func = &myFunc;

	myFunc.indIdx = i;
	myMinimizer.Reset(3);
	myMinimizer.point = startingPoint;
	myMinimizer.Minimize(1e-6);
	double fIBD = VerifyBamID::invLogit(myMinimizer.point[0]);
	double pRefHet = VerifyBamID::invLogit(myMinimizer.point[1]);
	double pRefAlt = VerifyBamID::invLogit(myMinimizer.point[2]);

	Logger::gLogger->writeLog("Comparing with individual %s.. Optimal fIBD = %lf, LLK0 = %lf, LLK1 = %lf for readgroup %d",vbid.pGenotypes->indids[i].c_str(), fIBD, myFunc.llk0, myFunc.llk1, rg);
	//Logger::gLogger->writeLog("Optimal per-sample fIBD = %lf, ",fIBD);
	Logger::gLogger->writeLog("Reference Bias Estimated as ( Pr[refBase|HET] = %lf, Pr[refBase|ALT] = %lf ) with LLK = %lf",pRefHet,pRefAlt,myMinimizer.fmin);
	if ( maxIBD < fIBD ) {
	  bestInds[rg+1] = i;
	  maxIBD = fIBD;
	  vbid.bestOut.llk0s[rg+1] = myFunc.llk0;
	  vbid.bestOut.llk1s[rg+1] = myFunc.llk1;
	  vbid.bestOut.fMixs[rg+1] = 1.-myFunc.fIBD;
	  vbid.bestOut.refHets[rg+1] = myFunc.pRefHet;
	  vbid.bestOut.refAlts[rg+1] = myFunc.pRefAlt;
	}

	if ( ( (rg < 0) && (vbid.pPile->sBamSMID == vbid.pGenotypes->indids[i] ) ) || ( ( rg >= 0 ) && ( vbid.pPile->vsSMIDs[rg] == vbid.pGenotypes->indids[i]) ) ) {
	  selfInds[rg+1] = i;
	  vbid.selfOut.llk0s[rg+1] = myFunc.llk0;
	  vbid.selfOut.llk1s[rg+1] = myFunc.llk1;
	  vbid.selfOut.fMixs[rg+1] = 1.-myFunc.fIBD;
	  vbid.selfOut.refHets[rg+1] = myFunc.pRefHet;
	  vbid.selfOut.refAlts[rg+1] = myFunc.pRefAlt;
	  vbid.calculateDepthByGenotype(i, rg, vbid.selfOut);
	}
      }
      //vbid.setRefBiasParams(1.0, pRefHet, pRefAlt);
      if ( bestInds[rg+1] >= 0 ) {
	Logger::gLogger->writeLog("Best Matching Individual is %s with IBD = %lf",vbid.pGenotypes->indids[bestInds[rg+1]].c_str(),maxIBD);
	vbid.calculateDepthByGenotype(bestInds[rg+1], rg, vbid.bestOut);
      }

      if ( selfInds[rg+1] >= 0 ) {
	Logger::gLogger->writeLog("Self Individual is %s with IBD = %lf",vbid.pGenotypes->indids[selfInds[rg+1]].c_str(),vbid.selfOut.fMixs[rg+1]);
	vbid.calculateDepthByGenotype(selfInds[rg+1],rg,vbid.selfOut);
      }
    }
  }

  // PRINT OUTPUT FILE - ".selfSM"
  // [SEQ_ID]  : SAMPLE ID in the sequence file
  // [CHIP_ID] : SAMPLE ID in the chip file (NA if not available)
  // [#SNPS] : Number of markers evaluated
  // [#READS]   : Number of reads evaluated
  // [AVG_DP]   : Mean depth
  // [FREEMIX]  : Chip-free estimated alpha (% MIX in 0-1 scale), NA if unavailable
  // [FREELK1]  : Chip-free log-likelihood at estimated alpha
  // [FREELK0]  : Chip-free log-likelihood at 0% contamination
  // [CHIPIBD]  : With-chip estimated alpha (% MIX in 0-1 scale)
  // [CHIPLK1]  : With-chip log-likelihood at estimated alpha
  // [CHIPLK0]  : With-chip log-likelihood at 0% contamination
  // [DPREF]    : Depth at reference site in the chip
  // [RDPHET]   : Relative depth at HET site in the chip
  // [RDPALT]   : Relative depth at HOMALT site in the chip
  // [FREE_RF]  : Pr(Ref|Ref) site estimated without chip data
  // [FREE_RH]  : Pr(Ref|Het) site estimated without chip data
  // [FREE_RA]  : Pr(Ref|Alt) site estimated without chip data
  // [CHIP_RF]  : Pr(Ref|Ref) site estimated with chip data
  // [CHIP_RH]  : Pr(Ref|Het) site estimated with chip data
  // [CHIP_RA]  : Pr(Ref|Alt) site estimated with chip data
  // [DPREF]    : Depth at reference alleles
  // [RDPHET]   : Relative depth at heterozygous alleles
  // [RDPALT]   : Relative depth at hom-alt alleles

  String selfSMFN = args.sOutFile + ".selfSM";
  String bestSMFN = args.sOutFile + ".bestSM";
  String selfRGFN = args.sOutFile + ".selfRG";
  String bestRGFN = args.sOutFile + ".bestRG";
  String dpSMFN = args.sOutFile + ".depthSM";
  String dpRGFN = args.sOutFile + ".depthRG";

  IFILE selfSMF = ifopen(selfSMFN,"wb");
  IFILE bestSMF = (args.bFindBest ? ifopen(bestSMFN,"wb") : NULL);
  IFILE selfRGF = (args.bIgnoreRG ? NULL : ifopen(selfRGFN,"wb"));
  IFILE bestRGF = (args.bFindBest && !args.bIgnoreRG) ? ifopen(bestRGFN,"wb") : NULL;

  IFILE dpSMF = ifopen(dpSMFN,"wb");
  IFILE dpRGF = (args.bIgnoreRG ? NULL : ifopen(dpRGFN,"wb"));
  if ( selfSMF == NULL ) {
    Logger::gLogger->error("Cannot write to %s",selfSMF);
  }
  if ( args.bFindBest && ( bestSMF == NULL ) ) {
    Logger::gLogger->error("Cannot write to %s",bestSMF);
  }
  if ( dpSMF == NULL ) {
    Logger::gLogger->error("Cannot write to %s",dpSMF);
  }

  ifprintf(dpSMF,"#RG\tDEPTH\t#SNPs\t%%SNPs\t%%CUMUL\n");
  int nCumMarkers = 0;
  for(int i=args.maxDepth; i >= 0; --i) {
    nCumMarkers += vbid.mixOut.depths[i];
    ifprintf(dpSMF,"ALL\t%d\t%d\t%.5lf\t%.5lf\n",i, vbid.mixOut.depths[i],(double) vbid.mixOut.depths[i]/(double)vbid.nMarkers,(double)nCumMarkers/(double)vbid.nMarkers);
  }
  ifclose(dpSMF);


  if ( dpRGF != NULL ) {
    ifprintf(dpRGF,"#RG\tDEPTH\t#SNPs\t%%SNPs\t%%CUMUL\n");
    for(int rg=0; rg < (vbid.nRGs - (int)args.bIgnoreRG); ++rg) {
      const char* rgID = vbid.pPile->vsRGIDs[rg].c_str();

      int nMarkers = 0;
      for(int i=args.maxDepth; i >= 0; --i) {
	nMarkers += vbid.mixOut.depths[(rg+1)*(args.maxDepth+1) + i];
      }

      nCumMarkers = 0;
      for(int i=args.maxDepth; i >= 0; --i) {
	int d = vbid.mixOut.depths[(rg+1)*(args.maxDepth+1) + i];
	nCumMarkers += d;
	ifprintf(dpRGF,"%s\t%d\t%d\t%.5lf\t%.5lf\n",rgID,i,d,(double)d/(double)vbid.nMarkers,(double)nCumMarkers/(double)nMarkers);
      }
    }
    ifclose(dpRGF);
  }

  const char* headers[] = {"#SEQ_ID","RG","CHIP_ID","#SNPS","#READS","AVG_DP","FREEMIX","FREELK1","FREELK0","FREE_RH","FREE_RA","CHIPMIX","CHIPLK1","CHIPLK0","CHIP_RH","CHIP_RA","DPREF","RDPHET","RDPALT"};
  int nheaders = sizeof(headers)/sizeof(headers[0]);

  for(int i=0; i < nheaders; ++i) { ifprintf(selfSMF,"%s%s",i>0 ? "\t" : "",headers[i]); }
  ifprintf(selfSMF,"\n");
  ifprintf(selfSMF,"%s\tALL",vbid.pPile->sBamSMID.c_str());
  ifprintf(selfSMF,"\t%s",selfInds[0] >= 0 ? vbid.pGenotypes->indids[selfInds[0]].c_str() : "NA");
  ifprintf(selfSMF,"\t%d\t%d\t%.2lf",vbid.nMarkers,vbid.mixOut.numReads[0],(double)vbid.mixOut.numReads[0]/(double)vbid.nMarkers);
  if ( args.bFreeNone ) { ifprintf(selfSMF,"\tNA\tNA\tNA\tNA\tNA"); }
  else if ( args.bFreeMixOnly ) { ifprintf(selfSMF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA",vbid.mixOut.fMixs[0],vbid.mixOut.llk1s[0],vbid.mixOut.llk0s[0]); }
  else if ( args.bFreeRefBiasOnly ) { ifprintf(selfSMF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.llk1s[0],vbid.mixOut.llk0s[0],vbid.mixOut.refHets[0],vbid.mixOut.refAlts[0]); }
  else if ( args.bFreeFull ) { ifprintf(selfSMF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.fMixs[0],vbid.mixOut.llk1s[0],vbid.mixOut.llk0s[0],vbid.mixOut.refHets[0],vbid.mixOut.refAlts[0]); }
  else { error("Invalid option in handling bFree"); }

  if ( args.bChipNone || bestInds[0] < 0 ) { ifprintf(selfSMF,"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"); }
  else if ( args.bChipMixOnly ) { ifprintf(selfSMF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA\t%.3lf\t%.4lf\t%.4lf",vbid.selfOut.fMixs[0],vbid.selfOut.llk1s[0],vbid.selfOut.llk0s[0],(double)vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[1], (double)vbid.selfOut.numReads[2]*vbid.selfOut.numGenos[1]/vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[2], (double)vbid.selfOut.numReads[3]*vbid.selfOut.numGenos[1]/vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[3]); }
  else if ( args.bChipMixOnly ) { ifprintf(selfSMF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf",vbid.selfOut.llk1s[0], vbid.selfOut.llk0s[0], vbid.selfOut.refHets[0], vbid.selfOut.refAlts[0], (double)vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[1], (double)vbid.selfOut.numReads[2]*vbid.selfOut.numGenos[1]/vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[2], (double)vbid.selfOut.numReads[3]*vbid.selfOut.numGenos[1]/vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[3]); }
  else if ( args.bChipFull ) { ifprintf(selfSMF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf", vbid.selfOut.fMixs[0], vbid.selfOut.llk1s[0], vbid.selfOut.llk0s[0], vbid.selfOut.refHets[0], vbid.selfOut.refAlts[0], (double)vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[1], (double)vbid.selfOut.numReads[2]*vbid.selfOut.numGenos[1]/vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[2], (double)vbid.selfOut.numReads[3]*vbid.selfOut.numGenos[1]/vbid.selfOut.numReads[1]/vbid.selfOut.numGenos[3]); }
  else { error("Invalid option in handling bChip"); }
  ifprintf(selfSMF,"\n");
  ifclose(selfSMF);

  if ( bestSMF != NULL ) {
    for(int i=0; i < nheaders; ++i) { ifprintf(bestSMF,"%s%s",i>0 ? "\t" : "",headers[i]); }
    ifprintf(bestSMF,"\n");
    ifprintf(bestSMF,"%s\tALL",vbid.pPile->sBamSMID.c_str());
    ifprintf(bestSMF,"\t%s",bestInds[0] >= 0 ? vbid.pGenotypes->indids[bestInds[0]].c_str() : "NA");
    ifprintf(bestSMF,"\t%d\t%d\t%.2lf",vbid.nMarkers,vbid.mixOut.numReads[0],(double)vbid.mixOut.numReads[0]/(double)vbid.nMarkers);
    if ( args.bFreeNone ) { ifprintf(bestSMF,"\tNA\tNA\tNA\tNA\tNA"); }
    else if ( args.bFreeMixOnly ) { ifprintf(bestSMF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA",vbid.mixOut.fMixs[0],vbid.mixOut.llk1s[0],vbid.mixOut.llk0s[0]); }
    else if ( args.bFreeRefBiasOnly ) { ifprintf(bestSMF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.llk1s[0],vbid.mixOut.llk0s[0],vbid.mixOut.refHets[0],vbid.mixOut.refAlts[0]); }
    else if ( args.bFreeFull ) { ifprintf(bestSMF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.fMixs[0],vbid.mixOut.llk1s[0],vbid.mixOut.llk0s[0],vbid.mixOut.refHets[0],vbid.mixOut.refAlts[0]); }
    else { error("Invalid option in handling bFree"); }
    
    if ( args.bChipNone || bestInds[0] < 0 ) { ifprintf(bestSMF,"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"); }
    else if ( args.bChipMixOnly ) { ifprintf(bestSMF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA\t%.3lf\t%.4lf\t%.4lf",vbid.bestOut.fMixs[0],vbid.bestOut.llk1s[0],vbid.bestOut.llk0s[0],(double)vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[1], (double)vbid.bestOut.numReads[2]*vbid.bestOut.numGenos[1]/vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[2], (double)vbid.bestOut.numReads[3]*vbid.bestOut.numGenos[1]/vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[3]); }
    else if ( args.bChipMixOnly ) { ifprintf(bestSMF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf",vbid.bestOut.llk1s[0], vbid.bestOut.llk0s[0], vbid.bestOut.refHets[0], vbid.bestOut.refAlts[0], (double)vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[1], (double)vbid.bestOut.numReads[2]*vbid.bestOut.numGenos[1]/vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[2], (double)vbid.bestOut.numReads[3]*vbid.bestOut.numGenos[1]/vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[3]); }
    else if ( args.bChipFull ) { ifprintf(bestSMF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf", vbid.bestOut.fMixs[0], vbid.bestOut.llk1s[0], vbid.bestOut.llk0s[0], vbid.bestOut.refHets[0], vbid.bestOut.refAlts[0], (double)vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[1], (double)vbid.bestOut.numReads[2]*vbid.bestOut.numGenos[1]/vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[2], (double)vbid.bestOut.numReads[3]*vbid.bestOut.numGenos[1]/vbid.bestOut.numReads[1]/vbid.bestOut.numGenos[3]); }
    else { error("Invalid option in handling bChip"); }
    ifprintf(bestSMF,"\n");
    ifclose(bestSMF);
  }

  if ( selfRGF != NULL ) {
    for(int i=0; i < nheaders; ++i) { ifprintf(selfRGF,"%s%s",i>0 ? "\t" : "",headers[i]); }
    ifprintf(selfRGF,"\n");
    for(int rg=0; rg < vbid.nRGs; ++rg) {
      ifprintf(selfRGF,"%s\t%s",vbid.pPile->sBamSMID.c_str(),vbid.pPile->vsRGIDs[rg].c_str());
      ifprintf(selfRGF,"\t%s",bestInds[rg] >= 0 ? vbid.pGenotypes->indids[bestInds[rg]].c_str() : "NA");
      ifprintf(selfRGF,"\t%d\t%d\t%.2lf",vbid.nMarkers,vbid.mixOut.numReads[(rg+1)*4],(double)vbid.mixOut.numReads[(rg+1)*4]/(double)vbid.mixOut.numGenos[(rg+1)*4]);
      if ( args.bFreeNone ) { ifprintf(selfRGF,"\tNA\tNA\tNA\tNA\tNA"); }
      else if ( args.bFreeMixOnly ) { ifprintf(selfRGF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA",vbid.mixOut.fMixs[rg+1],vbid.mixOut.llk1s[rg+1],vbid.mixOut.llk0s[rg+1]); }
      else if ( args.bFreeRefBiasOnly ) { ifprintf(selfRGF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.llk1s[rg+1],vbid.mixOut.llk0s[rg+1],vbid.mixOut.refHets[rg+1],vbid.mixOut.refAlts[rg+1]); }
      else if ( args.bFreeFull ) { ifprintf(selfRGF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.fMixs[rg+1],vbid.mixOut.llk1s[rg+1],vbid.mixOut.llk0s[rg+1],vbid.mixOut.refHets[rg+1],vbid.mixOut.refAlts[rg+1]); }
      else { error("Invalid option in handling bFree"); }
      
      if ( args.bChipNone || bestInds[0] < 0 ) { ifprintf(selfRGF,"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"); }
      else if ( args.bChipMixOnly ) { ifprintf(selfRGF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA\t%.3lf\t%.4lf\t%.4lf",vbid.selfOut.fMixs[rg+1], vbid.selfOut.llk1s[rg+1], vbid.selfOut.llk0s[rg+1], (double)vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+1], (double)vbid.selfOut.numReads[(rg+1)*4+2]*vbid.selfOut.numGenos[(rg+1)*4+1]/vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+2], (double)vbid.selfOut.numReads[(rg+1)*4+3]*vbid.selfOut.numGenos[(rg+1)*4+1]/vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+3]); }
      else if ( args.bChipMixOnly ) { ifprintf(selfRGF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf",vbid.selfOut.llk1s[rg+1], vbid.selfOut.llk0s[rg+1], vbid.selfOut.refHets[rg+1], vbid.selfOut.refAlts[rg+1], (double)vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+1], (double)vbid.selfOut.numReads[(rg+1)*4+2]*vbid.selfOut.numGenos[(rg+1)*4+1]/vbid.selfOut.numReads[(rg+1)*4]/vbid.selfOut.numGenos[(rg+1)*4+2], (double)vbid.selfOut.numReads[(rg+1)*4+3]*vbid.selfOut.numGenos[(rg+1)*4+1]/vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+3]); }
      else if ( args.bChipFull ) { ifprintf(selfRGF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf", vbid.selfOut.fMixs[rg+1], vbid.selfOut.llk1s[rg+1], vbid.selfOut.llk0s[rg+1], vbid.selfOut.refHets[rg+1], vbid.selfOut.refAlts[rg+1], (double)vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+1], (double)vbid.selfOut.numReads[(rg+1)*4+2]*vbid.selfOut.numGenos[(rg+1)*4+1]/vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+2], (double)vbid.selfOut.numReads[(rg+1)*4+3]*vbid.selfOut.numGenos[(rg+1)*4+1]/vbid.selfOut.numReads[(rg+1)*4+1]/vbid.selfOut.numGenos[(rg+1)*4+3]); }
      else { error("Invalid option in handling bChip"); }
      ifprintf(selfRGF,"\n");
    }
    ifclose(selfRGF);
  }

  if ( bestRGF != NULL ) {
    for(int i=0; i < nheaders; ++i) { ifprintf(bestRGF,"%s%s",i>0 ? "\t" : "",headers[i]); }
    ifprintf(bestRGF,"\n");
    for(int rg=0; rg < vbid.nRGs; ++rg) {
      ifprintf(bestRGF,"%s\t%s",vbid.pPile->sBamSMID.c_str(),vbid.pPile->vsRGIDs[rg].c_str());
      ifprintf(bestRGF,"\t%s",bestInds[rg] >= 0 ? vbid.pGenotypes->indids[bestInds[rg]].c_str() : "NA");
      ifprintf(bestRGF,"\t%d\t%d\t%.2lf",vbid.nMarkers,vbid.mixOut.numReads[(rg+1)*4],(double)vbid.mixOut.numReads[(rg+1)*4]/(double)vbid.mixOut.numGenos[(rg+1)*4]);
      if ( args.bFreeNone ) { ifprintf(bestRGF,"\tNA\tNA\tNA\tNA\tNA"); }
      else if ( args.bFreeMixOnly ) { ifprintf(bestRGF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA",vbid.mixOut.fMixs[rg+1],vbid.mixOut.llk1s[rg+1],vbid.mixOut.llk0s[rg+1]); }
      else if ( args.bFreeRefBiasOnly ) { ifprintf(bestRGF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.llk1s[rg+1],vbid.mixOut.llk0s[rg+1],vbid.mixOut.refHets[rg+1],vbid.mixOut.refAlts[rg+1]); }
      else if ( args.bFreeFull ) { ifprintf(bestRGF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf",vbid.mixOut.fMixs[rg+1],vbid.mixOut.llk1s[rg+1],vbid.mixOut.llk0s[rg+1],vbid.mixOut.refHets[rg+1],vbid.mixOut.refAlts[rg+1]); }
      else { error("Invalid option in handling bFree"); }
      
      if ( args.bChipNone || bestInds[0] < 0 ) { ifprintf(bestRGF,"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"); }
      else if ( args.bChipMixOnly ) { ifprintf(bestRGF,"\t%.5lf\t%.2lf\t%.2lf\tNA\tNA\t%.3lf\t%.4lf\t%.4lf",vbid.bestOut.fMixs[rg+1], vbid.bestOut.llk1s[rg+1], vbid.bestOut.llk0s[rg+1], (double)vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+1], (double)vbid.bestOut.numReads[(rg+1)*4+2]*vbid.bestOut.numGenos[(rg+1)*4+1]/vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+2], (double)vbid.bestOut.numReads[(rg+1)*4+3]*vbid.bestOut.numGenos[(rg+1)*4+1]/vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+3]); }
      else if ( args.bChipMixOnly ) { ifprintf(bestRGF,"\tNA\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf",vbid.bestOut.llk1s[rg+1], vbid.bestOut.llk0s[rg+1], vbid.bestOut.refHets[rg+1], vbid.bestOut.refAlts[rg+1], (double)vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+1], (double)vbid.bestOut.numReads[(rg+1)*4+2]*vbid.bestOut.numGenos[(rg+1)*4+1]/vbid.bestOut.numReads[(rg+1)*4]/vbid.bestOut.numGenos[(rg+1)*4+2], (double)vbid.bestOut.numReads[(rg+1)*4+3]*vbid.bestOut.numGenos[(rg+1)*4+1]/vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+3]); }
      else if ( args.bChipFull ) { ifprintf(bestRGF,"\t%.5lf\t%.2lf\t%.2lf\t%.5lf\t%.5lf\t%.3lf\t%.4lf\t%.4lf", vbid.bestOut.fMixs[rg+1], vbid.bestOut.llk1s[rg+1], vbid.bestOut.llk0s[rg+1], vbid.bestOut.refHets[rg+1], vbid.bestOut.refAlts[rg+1], (double)vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+1], (double)vbid.bestOut.numReads[(rg+1)*4+2]*vbid.bestOut.numGenos[(rg+1)*4+1]/vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+2], (double)vbid.bestOut.numReads[(rg+1)*4+3]*vbid.bestOut.numGenos[(rg+1)*4+1]/vbid.bestOut.numReads[(rg+1)*4+1]/vbid.bestOut.numGenos[(rg+1)*4+3]); }
      else { error("Invalid option in handling bChip"); }
      ifprintf(bestRGF,"\n");
    }
    ifclose(bestRGF);
  }
  
  time(&t);
  Logger::gLogger->writeLog("Analysis finished on %s",ctime(&t));

  return 0;
}
