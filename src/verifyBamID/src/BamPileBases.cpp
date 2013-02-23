#include "BamPileBases.h"
#include "CigarRoller.h"
#include "Logger.h"
#include <set>

// construct BamPileBases object from bamFile
BamPileBases::BamPileBases(const char* bamFile, const char* smID, bool ignoreRG) : bIgnoreRG(ignoreRG) {
  // open BAM File
  if ( ! inBam.OpenForRead( bamFile )  ) {
    Logger::gLogger->error("Cannot open BAM file %s for reading - %s", bamFile, SamStatus::getStatusString(inBam.GetStatus()) );
  }
  // read header
  inBam.ReadHeader(inHeader);
  
  // set index name as *.bam.bai"
  std::string sIndexFile = bamFile;
  sIndexFile += ".bai";
  
  // read index file
  FILE* fp = fopen(sIndexFile.c_str(),"rb");
  if ( fp != NULL ) {
    fclose(fp);
    inBam.ReadBamIndex( sIndexFile.c_str() );
  }
  else {
    // if index does not exist, set index name as *.bai and try again
    sIndexFile = bamFile;
    sIndexFile[sIndexFile.size()-1] = 'i';
    if ( ! inBam.ReadBamIndex( sIndexFile.c_str() ) ) {
      Logger::gLogger->error("Cannot open BAM file index %s for reading %s", sIndexFile.c_str(),bamFile);
    }
  }

  bSameSMFlag = true;
  
  Logger::gLogger->writeLog("Reading header Records");
  
  // read through header records to get the readGroup ID and corresponding sample ID. 
  // It also checkes whether the sequenceName matches with the specified convention
  SamHeaderRecord* pSamHeaderRecord;
  int refID = 0;
  while( (pSamHeaderRecord = inHeader.getNextHeaderRecord()) != NULL ) {
    if ( pSamHeaderRecord->getType() == SamHeaderRecord::RG ) {
      std::string sRGID(bIgnoreRG ? "ALL_RG" : pSamHeaderRecord->getTagValue("ID"));
      std::string sSMID(pSamHeaderRecord->getTagValue("SM"));
      if ( smID != NULL ) { sSMID = smID; }

      if ( sRGID.empty() ) {
	Logger::gLogger->error("Readgroup ID is empty");
      }
      if ( sSMID.empty() ) {
	Logger::gLogger->warning("SM tag is missing in read group %s",sRGID.c_str());
      }
      if ( (!bIgnoreRG) || (vsRGIDs.size() == 0) ) {
	vsRGIDs.push_back(sRGID);
	vsSMIDs.push_back(sSMID);

	if ( sBamSMID.empty() ) {
	  sBamSMID = sSMID;
	}
	else if ( sBamSMID.compare(sSMID) != 0 ) {
	  Logger::gLogger->warning("SM is not identical across the readGroups. Ignoring .bestSM/.selfSM outputs");
	  bSameSMFlag = false;
	}

	int rgIdx = msRGidx.size();
	msRGidx[sRGID] = (uint16_t)rgIdx;
      }
    }
    else if ( pSamHeaderRecord->getType() == SamHeaderRecord::SQ ) {
      std::string sSN = pSamHeaderRecord->getTagValue("SN");
      mSN2RefID[sSN] = refID;
      ++refID;
    }
  }

  if ( bIgnoreRG ) {
    //fprintf(stderr,"*** --bIgnoreRG is set\n");
    if ( vsRGIDs.size() == 0 ) {
      vsRGIDs.push_back("ALL_RG");
      vsSMIDs.push_back( (smID == NULL) ? "UNKNOWN_SM" : smID);
    }
    else if ( vsRGIDs.size() == 1 ) { // do nothing
    }
    else {
      error("vsRGIDs.size() > 1 with --ignoreRG option");
    }
    bSameSMFlag = true;
    sBamSMID = vsSMIDs[0];
    msRGidx["ALL_RG"] = (uint16_t)0;
  }
}

int BamPileBases::readMarker(const char* chrom, int position, bool ignoreOverlapPair) {
  SamRecord samRecord;
  std::string cigar;
  CigarRoller cigarRoller;
  std::set<std::string> readNames;
  nBegins.push_back(cBases.size());
  // check if chrom exist
  if ( mSN2RefID.find(chrom) == mSN2RefID.end() ) {
    // if refID is not found in SN, provide warning
    Logger::gLogger->warning("Cannot find sequence name %s appeared in VCF file but not in the BAM file, perhaps the reference is incompatible?\nThese markers will be ignored..");
    nEnds.push_back(cBases.size());
  }
  else {
    int refID = mSN2RefID[chrom];

    // **** Rouitine for reading each read
    if ( refID >= 0 ) {
      // set bam file to retrieve the reads overlapping with the particular genomic position chr(refID):bp(pos) 
      inBam.SetReadSection( refID, position-1, position ); 

      // Keep reading records until they aren't anymore.
      while(inBam.ReadRecord(inHeader, samRecord)) {
	//++numSectionRecords;

	// filtering step - mapQ
	if ( samRecord.getMapQuality() < minMapQ ) 
	  continue;

	// skip flagged reads
	uint16_t samFlags = samRecord.getFlag();
	if ( includeSamFlag && ( ( samFlags & includeSamFlag ) != includeSamFlag ) )
	  continue;
	if ( excludeSamFlag && ( samFlags & excludeSamFlag ) )
	  continue;

	// obtain readGroup info and store to rgIdx
	char tag[3];
	char vtype;
	void* value;
	bool found = false;
	uint16_t rgIdx;
	while( samRecord.getNextSamTag(tag, vtype, &value) != false ) {
	  if ( strcmp(tag, "RG") == 0 ) {
	    found = true;
	    if ( vtype == 'Z' ) {
	      std::string sValue = bIgnoreRG ? "ALL_RG" : ((String)*(String*)value).c_str();
	      if ( msRGidx.find(sValue) != msRGidx.end() ) {
		rgIdx = msRGidx[sValue];
	      }
	      else {
		Logger::gLogger->error("ReadGroup ID %s cannot be found",sValue.c_str());
	      }
	    }
	    else {
	      Logger::gLogger->error("vtype of RG tag must be 'Z'");
	    }
	  }
	}
	if ( found == false ) {
	  rgIdx = 0;
	  //Logger::gLogger->error("Cannot find RG tag for readName %s",samRecord.getReadName());
	}

	// access the base calls and qualities
	uint32_t readStartPosition = samRecord.get1BasedPosition();
	int32_t offset = position - readStartPosition;
	const char* readQuality = samRecord.getQuality();
	const char* readSequence = samRecord.getSequence();

	cigar = samRecord.getCigar();
	cigarRoller.Set(cigar.c_str());

	if ( offset >= 0 ) {
	  int32_t readIndex = cigarRoller.getQueryIndex(offset);
	  bool unique = ignoreOverlapPair ? true : readNames.insert(samRecord.getReadName()).second;
	  //if ( !unique ) 
	  //  error("foo -- detected overlapping paired end read for %s\n",samRecord.getReadName());

	  if ( unique && ( readIndex != CigarRoller::INDEX_NA ) ) {
	    if ( ( static_cast<int>(readQuality[readIndex]) >= minQ + 33 ) && ( readSequence[readIndex] != 'N' ) ) {
	      nRGIndices.push_back(rgIdx);
	      cBases.push_back(readSequence[readIndex]);
	      cQuals.push_back(readQuality[readIndex]);
	      cMapQs.push_back(samRecord.getMapQuality());
	    }
	  }
	}
	if ( (int)(cBases.size() - nBegins.back()) >= maxDepth ) break;
      }
    }
    nEnds.push_back(cBases.size());
  }
  return nEnds.back()-nBegins.back();
}
