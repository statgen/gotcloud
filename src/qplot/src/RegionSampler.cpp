#include "RegionSampler.h"
#include "GenomeSequence.h"
#include "InputFile.h"
#include "Constant.h"
#include <algorithm>
#include <set>

#undef DEBUG
#define DEBUG

struct Region {
  Region(int chr, int beg, int end, int weight):
      chrom(chr), begin(beg), end(end), weight(weight) {};
  Region() {};
  int chrom; // chromosome index
  int begin;
  int end;
  int weight;
};

int calcNBaseCount(GenomeSequence& ref, int chrom, int beg, int end) {
  genomeIndex_t b = ref.getGenomePosition(chrom, beg);
  genomeIndex_t e = ref.getGenomePosition(chrom, end);
  int c = 0;
  for (genomeIndex_t i = b; i <= e; ++i) {
    if (ref[i] == 'N')
      ++c;
  }
  return c;
}
int assignWeigth(GenomeSequence& ref, Region* r) {
  r->weight = (r->end - r->begin + 1) - calcNBaseCount(ref, r->chrom, r->begin, r->end);
  return 0;
}

void sampleRegions(std::vector<Region>* in, double fraction);
void mergeRegions(std::vector<Region>* regions);
int loadRegions(String& regionsFile, GenomeSequence& reference, std::vector<Region>* regions);
void invertRegions(GenomeSequence& ref, const std::vector<Region>& in, std::vector<Region>* invertRegion);

/**
 * @return true if @param is less than @param r
 */
bool compareRegion(const Region& l, const Region& r) {
  if (l.chrom < r.chrom) return true;
  if (l.chrom > r.chrom) return false;
  if (l.begin < r.begin) return true;
  if (l.begin > r.begin) return false;
  if (l.end < r.end) return true;
  if (l.end > r.end) return false;
  return false;
}

int RegionSampler::sampleGenome(GenomeSequence& ref, double fraction){
  // split whole genomes into chunks
  fprintf(stderr, "Sampling whole genome at %lf\n", fraction);
  this->reference = &ref;
  if (fraction < 0 ) return 0; // don't need to use fraction
  const int numRef = ref.getChromosomeCount();
  std::vector<Region> regions;

  for (int i = 0; i < numRef; ++i) {
    int size = ref.getChromosomeSize(i);
    int maxChunk = size / WHOLE_GENOME_CHUNK - 1;
    for (int j = 0; j < maxChunk ; ++j ){
      Region r(i, j * WHOLE_GENOME_CHUNK, (j+1) * WHOLE_GENOME_CHUNK, 1);
      assignWeigth(ref, &r);
      regions.push_back(r);
    }
  }

  sampleRegions(&regions, fraction);

  int lastRegion = -1;
  for (size_t i = 0; i < regions.size(); ++i) {
    if (lastRegion < 0 ) {
      appendRegion(regions[i]);
      lastRegion = regions[i].chrom;
      continue;
    }
    if (isAdjacentRegion(regions[i], 0)) {
      mergeRegion(regions[i], 0);
    } else{
      appendRegion(regions[i]);
    }
    lastRegion = regions[i].chrom;
  }

  // dump region
  dumpRegion();
  return 0;
}

/**
 * When target regions are of interests, we will make sampled regions
 * for on-target regions and off-target regions with given sampling @param fraction
 */
int RegionSampler::sampleWithRegion(GenomeSequence& ref, String& regionFile,
                                    bool invertRegion, double fraction){
  // split whole genomes into chunks

  this->reference = &ref;
  if (fraction < 0 ) {
    fprintf(stderr, "Disabling sampling methods\n");
    return 0; // don't need to use fraction
  } else {
    fprintf(stderr, "Sampling region file %lf\n", fraction);
  }

  std::vector<Region> regions;
  std::vector<Region> invertedRegions;
  loadRegions(regionFile, *this->reference, &regions);
  printf("Loaded %zu regions\n", regions.size());
  // if (invertRegion) {
  // printf("Inverting regions\n");
  invertRegions(ref, regions, &invertedRegions);
  // }

  sampleRegions(&regions, fraction);
  sampleRegions(&invertedRegions, fraction);
  for (size_t i = 0; i < invertedRegions.size(); ++i) {
    regions.push_back(invertedRegions[i]);
  }
  mergeRegions(&regions);
  std::sort(regions.begin(), regions.end(), compareRegion);
  
  // long int totalWeight = 0;
  // for (size_t i = 0; i < regions.size(); ++i) {
  //   totalWeight += regions[i].weight;
  // }

  // // shuffle
  // std::random_shuffle(regions.begin(), regions.end());

  // // select first @param fraction of samples
  // long int cutoffWeight = std::min(fraction, 1.0) * totalWeight;
  // long int weight = 0;
  // int newSize = 0;
  // while (weight < cutoffWeight) {
  //   weight += regions[newSize].weight;
  //   newSize ++;
  // }
  // regions.resize(newSize);

  // // sort and merge regions
  // std::sort(regions.begin(), regions.end(), compareRegion);


  int lastRegion = -1;
  for (size_t i = 0; i < regions.size(); ++i) {
    if (lastRegion < 0 ) {
      appendRegion(regions[i]);
      lastRegion = regions[i].chrom;
      continue;
    }
    if (isAdjacentRegion(regions[i], REGION_OVERLAP_THRESHOLD)) {
      mergeRegion(regions[i], REGION_OVERLAP_THRESHOLD);
    } else{
      appendRegion(regions[i]);
    }
    lastRegion = regions[i].chrom;
  }

  // dump region
  dumpRegion();
  return 0;
}

void RegionSampler::appendRegion(const Region& r) {
  this->chrom.push_back(this->reference->getChromosomeName(r.chrom));
  this->begin.push_back(r.begin);
  this->end.push_back(r.end);
}

/**
 * @return true if @param r is closer (distance less than @param threshold) to the last region
 */
bool RegionSampler::isAdjacentRegion(const Region& r, int threshold) {
  int lastChrom = this->reference->getChromosome(this->chrom[this->chrom.size() - 1].c_str());
  int lastBegin = this->begin[this->chrom.size() - 1];
  int lastEnd   = this->end  [this->chrom.size() - 1];

  if (!this->chrom.empty() && lastChrom == r.chrom &&
      (lastBegin < r.begin && r.begin <= lastEnd + threshold))
    return true;
  return false;
}

/**
 * Merge @param r with the last region
 */
void RegionSampler::mergeRegion(const Region& r, int threshold) {
  int lastChrom = this->reference->getChromosome(this->chrom.back().c_str());
  int lastBegin = this->begin.back();
  int lastEnd   = this->end.back();

  if (this->chrom.empty() || lastChrom != r.chrom) return;

  if (lastBegin < r.begin && r.begin <= lastEnd + threshold) {
    this->end.back() = (lastEnd > r.end ? lastEnd : r.end);
  }
}

void RegionSampler::dumpRegion() {
#ifndef DEBUG
  fprintf(stdout, "Dump region:\n");
  size_t n = this->chrom.size();
  for (size_t i = 0; i != n; ++i) {
    const char* chr = this->chrom[i].c_str();
    fprintf(stdout, "Region %zu\t %s:%d-%d\n", i, chr, this->begin[i], this->end[i]);
  }
#endif
}

/**
 * Load region file and store them in @param regions
 * a) if the regions not in reference, then discard it.
 * b) if regions are overlapping, they will be merged
 */
int loadRegions(String& regionsFile, GenomeSequence& reference, std::vector<Region>* regions) {
  IFILE fhRegions = ifopen(regionsFile.c_str(),"r");
  if(fhRegions==NULL) {
    fprintf(stderr, "Cannot open regions file %s failed!\n", regionsFile.c_str());
    return -1;
  }

  StringArray tokens;
  String buffer;

  fprintf(stderr, "Loading region list...");

  // record errors
  // int numError = 0;
  // const int MAX_ERROR = 20;
  // StringIntHash wrongChromosomeCount;

  while (!ifeof(fhRegions)){
    tokens.Clear();
    buffer.Clear();
    buffer.ReadLine(fhRegions);
    if (buffer.IsEmpty() || buffer[0] == '#') continue;

    tokens.AddTokens(buffer, WHITESPACE);
    if(tokens.Length() < 3) {
      continue;
    }

    genomeIndex_t startGenomeIndex = 0;

    long chromosomeBeginIndex;
    long chromosomeEndIndex;
    if (!tokens[1].AsInteger(chromosomeBeginIndex) || !tokens[2].AsInteger(chromosomeEndIndex)) {
      // numError ++;
      // fprintf(stderr, "WARNING: Chromosome position [ %s ] or [ %s ] is not recognized!\n", tokens[1].c_str(), tokens[2].c_str());
      // if (numError > MAX_ERROR) {
      //   fprintf(stderr, "Too many errors in your region file, now quitting....\n");
      //   exit(1);
      // }
      continue;
    }

    startGenomeIndex = reference.getGenomePosition(tokens[0].c_str(), chromosomeBeginIndex);
    if (startGenomeIndex == INVALID_GENOME_INDEX) {
      // numError ++;
      // we cannot print out each error, as some chromosome GLXXXX.XXX chromosome may not in reference genome
      // so we will just record the error
      // wrongChromosomeCount.IncrementCount(tokens[0]);
      continue;
    }

    int chrom = reference.getChromosome(tokens[0].c_str());
    int weight = chromosomeEndIndex - chromosomeBeginIndex;
    Region r(chrom, (int)chromosomeBeginIndex, (int)chromosomeEndIndex, weight);
    regions->push_back(r);
    tokens.Clear();
    buffer.Clear();
  }

  mergeRegions(regions);
  for(size_t i = 0; i < regions->size(); ++i){
    assignWeigth(reference, &(*regions)[i]);
  }
  return 0;
}

bool isSmallRegion(Region& r) {
  return (r.end - r.begin < RegionSampler::REGION_OVERLAP_THRESHOLD);
}

void invertRegions(GenomeSequence& ref, const std::vector<Region>& in, std::vector<Region>* invertRegion) {
  std::vector<Region>&  out = *invertRegion;
  if (in.empty()) return;

  std::set<int> chromInRegion;
  int lastChrom = -1;
  int lastEnd = 0;
  size_t numRegion = in.size();
  size_t i = 0;
  for (; i != numRegion; ++i) {
    chromInRegion.insert(in[i].chrom);
    if (lastChrom != in[i].chrom) {
      if (lastChrom != -1) {
        int totalChromLen = ref.getChromosomeSize(lastChrom);
        Region r (lastChrom, lastEnd, totalChromLen, totalChromLen - lastEnd);
        assignWeigth(ref, &r);
        out.push_back(r);
      }
      Region r (in[i].chrom, 0, in[i].begin, in[i].begin);
      assignWeigth(ref, &r);
      out.push_back(r);
      lastChrom = in[i].chrom;
      lastEnd = in[i].end;
      continue;
    }
    Region r (in[i].chrom, lastEnd, in[i].begin, in[i].begin - lastEnd);
    assignWeigth(ref, &r);
    out.push_back(r);
    lastEnd = in[i].end;
  }
  if (lastChrom != -1) {
    int totalChromLen = ref.getChromosomeSize(lastChrom);
    Region r (lastChrom, lastEnd, totalChromLen, totalChromLen - lastEnd);
    assignWeigth(ref, &r);
    out.push_back(r);
  }

  // add chromosomes that are not in the region list
  // similar to sampleGenome, we use WHOLE_GENOME_CHUNK chunk
  const int numRef = ref.getChromosomeCount();
  for (int i = 0; i < numRef; ++i) {
    if (chromInRegion.count(i)) continue;
    int size = ref.getChromosomeSize(i);
    int maxChunk = size / RegionSampler::WHOLE_GENOME_CHUNK - 1;
    for (int j = 0; j < maxChunk ; ++j ){
      Region r(i,
               j * RegionSampler::WHOLE_GENOME_CHUNK,
               (j+1) * RegionSampler::WHOLE_GENOME_CHUNK,
               RegionSampler::WHOLE_GENOME_CHUNK);
      assignWeigth(ref, &r);
      out.push_back(r);
    }
  }

  // filter out small regions
  // b/c before inverting, these regions should be merged before hand
  size_t newSize = std::remove_if(out.begin(), out.end(), isSmallRegion) - out.begin();
  out.resize(newSize);
}

void mergeRegions(std::vector<Region>* regions) {
  std::vector<Region>& r = *regions;
  std::vector<Region> out;
  std::sort(r.begin(), r.end(), compareRegion);

  int lastChrom = -1;
  size_t n = r.size();
  int idx = -1;
  for (size_t i = 0; i != n; ++i) {
    if (lastChrom != r[i].chrom) { // new chrom
      lastChrom = r[i].chrom;
      out.push_back(r[i]);
      idx ++;
      continue;
    }
    if (out[idx].end < r[i].begin) {
      out.push_back(r[i]);
      ++idx;
      continue;
    } else {
      out[idx].end = std::max(out[idx].end, r[i].end);
    }
  }
  std::swap(*regions, out);
}


void sampleRegions(std::vector<Region>* in, double fraction) {
  if (fraction < 0.0) return;
  if (fraction > 1.) fraction = 1.0;

  std::vector<Region>& regions = *in;

  long int totalWeight = 0;
  size_t num = regions.size();
  for (size_t i = 0; i < num; ++i)
    totalWeight  += regions[i].weight;

  // shuffle
  std::random_shuffle(regions.begin(), regions.end());

  // select first @param fraction of samples
  long int cutoffWeight = fraction * totalWeight;
  long int weight = 0;
  int newSize = 0;
  while (weight < cutoffWeight) {
    weight += regions[newSize].weight;
    newSize ++;
  }
  regions.resize(newSize);

  // sort and merge regions
  std::sort(regions.begin(), regions.end(), compareRegion);
}
