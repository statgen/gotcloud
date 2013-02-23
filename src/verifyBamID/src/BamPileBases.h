#ifndef __BAM_PILE_BASES__H
#define __BAM_PILE_BASES__H

#include <map>
#include <vector>
#include <string>
#include "Generic.h"
#include "SamFile.h"
#include "Logger.h"

class BamPileBases {
 public:
  // constructor
  BamPileBases(const char* bamFile, const char* smID = NULL, bool ignoreRG = false);

  // read a markers
  int readMarker(const char* chrom, int position, bool ignoreOverlapPair = false);

  // parameters (public)
  int minMapQ;
  int maxDepth;
  int minQ;
  int maxQ;
  uint16_t includeSamFlag;
  uint16_t excludeSamFlag;
  bool bIgnoreRG;

  std::vector<char> cBases;         // bases
  std::vector<char> cQuals;         // quals
  std::vector<char> cMapQs;
  std::vector<uint16_t> nRGIndices; // readgroup index
  std::vector<uint32_t> nBegins;    // m-th marker is begin <= i < end
  std::vector<uint32_t> nEnds;      // m-th marker is begin <= i < end

 //protected:
  SamFile inBam;
  SamFileHeader inHeader;

  // [read_group_name] -> [read_group_index_in_vsRGIDs]
  std::map<std::string,uint16_t> msRGidx;
  // list of [read_group_name]s
  std::vector<std::string> vsRGIDs;
  std::vector<std::string> vsSMIDs;
  // sample ID of the BAM (if only one)
  std::string sBamSMID;
  bool bSameSMFlag;
  // chr to refID map
  std::map<std::string,int> mSN2RefID;
};

#endif
