#ifndef _REGIONSAMPLER_H_
#define _REGIONSAMPLER_H_

#include <string>
#include <vector>

class String;
class GenomeSequence;
class Region;

class RegionSampler {
public:
  // caller function
  int sampleGenome(GenomeSequence& ref, double fraction);
  int sampleWithRegion(GenomeSequence& ref, String& regionFile, bool invertRegion, double fraction);

  // getters
  bool empty() { return this->chrom.empty();};
  const char* getChrom(int i) const{
    return this->chrom[i].c_str();
  }
  int getBegin(int i) const {
    return this->begin[i];
  }
  int getEnd(int i) const{
    return this->end[i];
  }
  size_t size() const {return this->chrom.size(); };
  
public:
  // consts
  const static int WHOLE_GENOME_CHUNK = 1e6;
  const static int REGION_OVERLAP_THRESHOLD = 1e3;

private:
  // accessor functions
  void appendRegion(const Region& r);
  bool isAdjacentRegion(const Region& r, int threshold);
  void mergeRegion(const Region& r, int threshold);
  void dumpRegion();

  GenomeSequence* reference;

  // these are sampled regions
  std::vector<std::string> chrom;
  std::vector<int> begin;
  std::vector<int> end;

};

#endif /* _REGIONSAMPLER_H_ */
