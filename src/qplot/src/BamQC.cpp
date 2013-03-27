#include "BamQC.h"
#include <cmath>
#include "InputFile.h"
#include "BgzfFileType.h" // to enable --noeof
#define INIT_LEN 1000

class Graph{
 public:
  void newPlot() {
    buffer << "<plot>";
  };
  void closePlot() {
    buffer << "</plot>";
  };
  void setTitle(const char* t) {
    buffer << "<title>";
    buffer << t;
    buffer << "</title>";
  }
  void setAxisTitle(const char* xaxis, const char* yaxis) {
    buffer << "<xaxis>";
    buffer << xaxis;
    buffer << "</xaxis>";
    buffer << "<yaxis>";
    buffer << yaxis;
    buffer << "</yaxis>";
  };
  void setXaxisTitle(const char* xaxis) {
    buffer << "<xaxis>";
    buffer << xaxis;
    buffer << "</xaxis>";
  }
  void setXaxisTitle(const char* xaxis, int xmin) {
    buffer << "<xaxis min=\"" << xmin << "\">";
    buffer << xaxis;
    buffer << "</xaxis>";
  }
  void setXaxisTitle(const char* xaxis, int xmin, int xmax) {
    buffer << "<xaxis min=\"" << xmin << "\" max = \"" << xmax << "\">";
    buffer << xaxis;
    buffer << "</xaxis>";
  }
  void setYaxisTitle(const char* yaxis) {
    buffer << "<yaxis>";
    buffer << yaxis;
    buffer << "</yaxis>";
  }
  void setYaxisTitle(const char* yaxis, int ymin) {
    buffer << "<yaxis min=\"";
    buffer << ymin;
    buffer << "\">";
    buffer << yaxis;
    buffer << "</yaxis>";
  }
  void setYaxisTitle(const char* yaxis, int ymin, int ymax) {
    buffer << "<yaxis min=\"";
    buffer << ymin;
    buffer << "\" max=\"";
    buffer << ymax;
    buffer << "\">";
    buffer << yaxis;
    buffer << "</yaxis>";
  }


  void addData(const char* label, const std::vector<double>& x, const std::vector<double>& y) {
    buffer << "<series label=\"";
    buffer << label;
    buffer << "\">";
    buffer << "<x>";
    for (unsigned int i = 0; i < x.size(); i++ ) {
      if (i)
        buffer << ',';
      buffer << (x[i]);
    };
    buffer << "</x>";
    buffer << "<y>";
    for (unsigned int i = 0; i < y.size(); i++ ) {
      if (i)
        buffer << ',';
      buffer << (y[i]);
    };
    buffer << "</y>";
    buffer << "</series>";
  }
  std::string dump() {
    std::string s;
    s = "<?xml version=\"1.0\"?>";
    s += "<graph>";
    s += this->buffer.str();
    s += "</graph>";
    return s;
  };
 public:
  std::ostringstream buffer;
};

// utility function
void dump(const char* s, const std::vector<double> x){
  printf("%s\t", s);
  for (unsigned int i = 0; i < x.size(); i++) {
    printf("%.2f, ", x[i]);
  }
  printf("\n");
};

BamQC::BamQC(){
  noDepth = false;
  noGC = false;
  page = 2;
}

BamQC::BamQC(StringArray &bams) {
  Init(bams, INIT_LEN);
}

BamQC::BamQC(StringArray &bams, int init_len) {
  Init(bams, init_len);
}

BamQC::~BamQC()
{
  if(stats) delete [] stats;
  stats = NULL;
}

void BamQC::Init(StringArray &bams, int len)
{
  bamFiles = bams;
  stats = new QCStats[bamFiles.Length()];
#if defined(BROKEN)
  // XXX broken because the above new operator calls
  // the constructor, which calls Init, but nothing
  // afterwards does a free...
  for(int i=0; i<bamFiles.Length(); i++)
    stats[i].Init(len);
#endif
  size = 0;
  refBaseNCount=0;
  noDepth = noGC = false;
  page = 2;
}

void BamQC::SkipCheckEof() {
  // turning off noef
  BgzfFileType::setRequireEofBlock(false);
}

void BamQC::SetLanes2Process(String &ln)
{
  lanes = ln;
  StringArray tokens;
  tokens.ReplaceTokens(ln, ",");
  for(int i=0; i<tokens.Length(); i++)
    lanes2Process[tokens[i].AsInteger()]++;
}

void BamQC::SetReadGroup2Process(String& rg)
{
  this->readGroup2Process.clear();
  StringArray tokens;
  tokens.ReplaceTokens(rg, ",");
  for(int i=0; i<tokens.Length(); i++)
    this->readGroup2Process.push_back(tokens[i].c_str());
};

void BamQC::CalculateQCStats(QSamFlag &filter, double minMapQuality)
{
  if(!noGC)
  {
    int winSize = 100;
    GC.SetGenomeSequence(&referencegenome, winSize);

    if(GCInputFile.Length()==0)
      error("GC content file not provided!\n");

    fprintf(stderr, "Reading GC content......");
    GC.ReadGCContent(GCInputFile);
    fprintf(stderr, "DONE!\n");
  }

  //
  //    if(page>1 && !noDepth) depthVec.AllocateMemory(referencegenome.sequenceLength());

  for(int i=0; i<bamFiles.Length(); i++)
  {
    fprintf(stderr, "Processing bam/sam file %s...\n", bamFiles[i].c_str());

    // if(page > 1 && !noDepth)
    //     depthVec.SetZeroCount();

    // Clear vector of indicator for genome position covered
    genomePosCovered.clear();
    genomePosCovered.resize(referencegenome.sequenceLength());
    // Setup appropriate pointers
    stats[i].SetReferenceGenome(&referencegenome);
    stats[i].SetdbSNPIndicator(&dbSNPIndicator);
    stats[i].SetRegionIndicator(&regionIndicator);
    stats[i].SetGenomePositionCoveredIndicator(&genomePosCovered);
    if(!noGC) stats[i].SetGCContent(&GC);
    if(page>1 && !noDepth) {
      stats[i].SetDepth(&depthVec);
      this->depthVec.clear();
    }

    SamFile sam;
    SamRecord samRecord;
    SamFileHeader samHeader;

    if(!sam.OpenForRead(bamFiles[i].c_str()))
      error("Open BAM file %s failed!\n", bamFiles[i].c_str());

    if(!sam.ReadHeader(samHeader)) {
      error("Read BAM file header %s failed!\n", bamFiles[i].c_str());
    }

    QSamFlag flag;

    uint64_t nRecords = 0;

    //
    // XXX This loop is processing all records, regardless
    // of whether they are mapped or not - is this the intention?
    //
    while(sam.ReadRecord(samHeader, samRecord))
    {
      //stats[i].PrintSamRecord(sam);
      flag.GetFlagFields(samRecord.getFlag());
      // XXX this call winds up processing unmapped records and prints error messsages:
      stats[i].UpdateStats(samRecord, filter, minMapQuality, lanes2Process, readGroup2Process);
      if(stats[i].size>size) size = stats[i].size;
      if(nRecords2Process>0 && (++nRecords)==unsigned(nRecords2Process)) break;
    }
    stats[i].ReportWarningCount();
    stats[i].CalcMisMatchRateByCycle();
    stats[i].CalcMisMatchRateByQual();
    stats[i].CalcGenomeCoverage(genomePosCovered, refBaseNCount);
    stats[i].CalcQ20Bases();
    stats[i].CalcQ20BasesByCycle();
    stats[i].CalcBaseComposition();
    stats[i].CalcInsertSize_mode();
    stats[i].CalcInsertSize_medium();
    if(page>1 && !noDepth) stats[i].CalcDepthDist();
    if(!noGC) stats[i].CalcDepthGC(GC, genomePosCovered);
    if(!noGC) stats[i].CalcGCBias(20, 80);
  }
}

void BamQC::SetQCStatsReferencePtr()
{

  for(int i=0; i<bamFiles.Length(); i++){
    stats[i].SetReferenceGenome(&referencegenome);
    stats[i].SetdbSNPIndicator(&dbSNPIndicator);
  }
}

void BamQC::CalcNBaseCount()
{
  for(uint32_t i=0; i<referencegenome.sequenceLength(); i++)
    if(toupper(referencegenome[i])=='N')
      refBaseNCount++;
}
void BamQC::LoadGenomeSequence(String & reference)
{
#pragma message "MemoryMap ON"
  bool memoryMap = true;
  fprintf(stderr,"Loading reference... ");

  referencegenome.setReferenceName(reference.c_str());

  if (referencegenome.open())
  {
    fprintf(stderr, "Failed to open reference index and is creating one...\n");
    if(referencegenome.create())
      error("Failed to create reference index!\n");
  }

  referencegenome.useMemoryMap(memoryMap);
  if(referencegenome.open())
    error("Open  reference failed...!\n");

  CalcNBaseCount();
  fprintf(stderr, "DONE! Total sequence length %u\n", referencegenome.sequenceLength());
}

void BamQC::LoaddbSNP(String & dbSNPFile)
{
  if(dbSNPFile.Length()==0) return;

  std::map<String, uint32_t> contigsSkipped;
  IFILE fdbSnp;
  fdbSnp = ifopen(dbSNPFile,"r");
  if(fdbSnp==NULL)
    error("Open dbSNP file %s failed!\n", dbSNPFile.c_str());

  dbSNPIndicator.resize(referencegenome.sequenceLength());

  StringArray tokens;
  String buffer;

  fprintf(stderr, "Loading dbSNP...");
  while (!ifeof(fdbSnp))
  {
    buffer.ReadLine(fdbSnp);
    if (buffer.IsEmpty() || buffer[0] == '#') continue;

    tokens.AddTokens(buffer, WHITESPACE);
    if(tokens.Length() < 2) continue;

    genomeIndex_t snpGenomeIndex = 0;
    int chromosomeIndex = tokens[1].AsInteger();

    snpGenomeIndex = referencegenome.getGenomePosition(tokens[0].c_str(), chromosomeIndex);

    if(snpGenomeIndex >= dbSNPIndicator.size() )
    {
      if(++contigsSkipped[tokens[0]]>0 && contigsSkipped[tokens[0]]==1)
        fprintf(stderr, "WARNING: dbSNP contig %s is not found in the reference and skipped...\n", tokens[0].c_str());
      continue;
    }
    dbSNPIndicator[snpGenomeIndex ] = true;

    tokens.Clear();
    buffer.Clear();
  }
  ifclose(fdbSnp);
  fprintf(stderr, "DONE!\n");
}

void BamQC::LoadRegions(String & regionsFile, bool invertRegion)
{
  if(regionsFile.Length()==0) return;

  IFILE fhRegions;
  fhRegions = ifopen(regionsFile.c_str(),"r");
  if(fhRegions==NULL)
    error("Open regions file %s failed!\n", regionsFile.c_str());

  regionIndicator.resize(referencegenome.sequenceLength());

  StringArray tokens;
  String buffer;
  int len;

  fprintf(stderr, "Loading region list...");

  while (!ifeof(fhRegions)){
    buffer.ReadLine(fhRegions);
    if (buffer.IsEmpty() || buffer[0] == '#') continue;

    tokens.AddTokens(buffer, WHITESPACE);
    if(tokens.Length() < 3) continue;

    genomeIndex_t startGenomeIndex = 0;

    int chromosomeIndex = tokens[1].AsInteger();

    startGenomeIndex = referencegenome.getGenomePosition(tokens[0].c_str(), chromosomeIndex);

    if(startGenomeIndex >= regionIndicator.size() ) {
      //fprintf(stderr, "WARNING: region list section %s position %u is not found in the reference and skipped...\n", tokens[0].c_str(), chromosomeIndex);
      continue;
    }

    len = tokens[2].AsInteger() - tokens[1].AsInteger() + 1;
    for(uint32_t i=startGenomeIndex; i<startGenomeIndex+len; i++)
      regionIndicator[i] = true;

    tokens.Clear();
    buffer.Clear();
  }

  uint64_t sites = 0;
  if (invertRegion) {
    fprintf(stderr, " invert region...");
    for (uint32_t i = 0; i < regionIndicator.size(); i++) {
      regionIndicator[i] = !regionIndicator[i];
      if (regionIndicator[i]) sites++;
    }
  } else {
    for (uint32_t i = 0; i < regionIndicator.size(); i++) {
      if (regionIndicator[i]) sites++;
    }
  }
  fprintf(stderr, " total region length = %lu ", sites);
  ifclose(fhRegions);

  if ( 0 == (int) sites ) {
    fprintf(stderr, "WARNING!! Your total region length is ZERO, please check your region file!");
  };

  fprintf(stderr, "DONE!\n");
  
}


void BamQC::OutputStats(String &statsFile)
{
  FILE *OUT;

  if(statsFile.Length()==0)
  {
    fprintf(stderr, "NOTICE: stats will be output to stdout!\n\n");
    OUT = stdout;
  }
  else OUT = fopen(statsFile.c_str(), "w");

  if(OUT==NULL) error("Open file %s failed!\n", statsFile.c_str());

  // Output header
  fprintf(OUT, "Stats\\BAM");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%s", bamFiles[i].c_str());

  // Output all statistics
  fprintf(OUT, "\nTotalReads(e6)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].nReads)/1000000);

  fprintf(OUT, "\nMappingRate(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", 100-100*double(stats[i].nUnMapped)/double(stats[i].nReads));

  fprintf(OUT, "\nMapRate_MQpass(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", 100-100*double(stats[i].nUnMapped_Filter)/stats[i].nReads);

  fprintf(OUT, "\nTargetMapping(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", 100*double(stats[i].nReadsMapped2TargetRegions)/stats[i].nReads);

  fprintf(OUT, "\nZeroMapQual(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].nZeroMapQual)/stats[i].nReads*100);

  fprintf(OUT, "\nMapQual<10(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].nLT10MapQual)/stats[i].nReads*100);

  fprintf(OUT, "\nPairedReads(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].nPaired)/stats[i].nReads*100);

  fprintf(OUT, "\nProperPaired(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].nProperPaired)/stats[i].nReads*100);

  fprintf(OUT, "\nMappedBases(e9)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].totalMappedBases)/1000000000);

  fprintf(OUT, "\nQ20Bases(e9)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", double(stats[i].nQ20)/1000000000);

  fprintf(OUT, "\nQ20BasesPct(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", stats[i].pQ20);

  fprintf(OUT, "\nMeanDepth");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", stats[i].coverage);

  fprintf(OUT, "\nGenomeCover(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", stats[i].genomeCoverage);

  fprintf(OUT, "\nEPS_MSE");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", stats[i].CalcMisMatchRateByQual_MSE());

  fprintf(OUT, "\nEPS_Cycle_Mean");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", stats[i].CalcMisMatchRateByCycle_MEAN());

  fprintf(OUT, "\nGCBiasMSE");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", stats[i].gcBiasStat);

  fprintf(OUT, "\nISize_mode");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%d", stats[i].insertSize_mode);

  fprintf(OUT, "\nISize_medium");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%d", stats[i].insertSize_medium);

  fprintf(OUT, "\nDupRate(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", 100*double(stats[i].nDup)/stats[i].nReads);

  fprintf(OUT, "\nQCFailRate(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.2f", 100*double(stats[i].nQCFail)/stats[i].nReads);

  fprintf(OUT, "\nBaseComp_A(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.1f", stats[i].baseComposition[0]);

  fprintf(OUT, "\nBaseComp_C(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.1f", stats[i].baseComposition[1]);

  fprintf(OUT, "\nBaseComp_G(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.1f", stats[i].baseComposition[2]);

  fprintf(OUT, "\nBaseComp_T(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.1f", stats[i].baseComposition[3]);

  fprintf(OUT, "\nBaseComp_O(%%)");
  for(int i=0; i<bamFiles.Length(); i++)
    fprintf(OUT, "\t%.1f", stats[i].baseComposition[4]+stats[i].baseComposition[5]);

  fprintf(OUT, "\n");

  if(statsFile.Length()>0)
    fclose(OUT);
}

void BamQC::OutputXML(FILE *fp)
{
  if(fp==NULL) return;

  StringArray bamLabelArray;
  if (bamLabel.Length() != 0) {
    bamLabelArray.ReplaceTokens(bamLabel, ",");
  } else  {
    bamLabelArray.Dimension(bamFiles.Length());
    for (int i = 0; i < bamFiles.Length(); i++) {
      bamLabelArray[i] = i + 1;
    }
  }

  Graph graph;
  std::string s;
  std::vector<double> x;
  std::vector<double> y;

  graph.newPlot();
  graph.setTitle("Empirical vs Reported");
  graph.setXaxisTitle("Reported Phred");
  graph.setYaxisTitle("Empirical Phred");
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    for(unsigned int i=0; i<stats[idx].qual.size(); i++)
    {
      x.push_back(stats[idx].qual[i]);
      if(stats[idx].misMatchRateByQual[stats[idx].qual[i]]==0)
        y.push_back(MAXQ);
      else
        y.push_back(double(-10*log10(stats[idx].misMatchRateByQual[stats[idx].qual[i]])));
    }
    graph.addData(bamLabelArray[idx].c_str(), x, y);
  }
  graph.closePlot();

  graph.newPlot();
  graph.setTitle("Base Count vs Reported Phred");
  graph.setXaxisTitle("Reported Phred");
  graph.setYaxisTitle("Base Count (million)");
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    vector<int>& q = stats[idx].qual;
    for(unsigned int i=0; i<stats[idx].qual.size(); i++)
    {
      x.push_back(stats[idx].qual[i]);
      y.push_back( double(stats[idx].qualCount[q[i]])/1000000 );
    }
    graph.addData(bamLabelArray[idx].c_str(), x, y);    
  }
  graph.closePlot();


  graph.newPlot();
  graph.setTitle("Empirical Phred per Cycle");
  graph.setXaxisTitle("Cycle");
  graph.setYaxisTitle("Empirical Phred", 0);
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    for(unsigned int i=0; i<stats[idx].qual.size(); i++)
    {
      if(stats[idx].misMatchRateByCycle[i]==-1){
        // x.push_back( i + 1);
        // y.push_back("NA");
      }else if(stats[idx].misMatchRateByCycle[i]==0) {
        x.push_back( i + 1);
        y.push_back(MAXQ);
      }else{
        x.push_back( i + 1);
        y.push_back(double(-10*log10(stats[idx].misMatchRateByCycle[i])));
      }
    }
    graph.addData(bamLabelArray[idx].c_str(), x, y);
  }
  graph.closePlot();

  // skip GenRscript_CycleDist_Data()
  
  graph.newPlot();
  graph.setTitle("GC Content");
  graph.setXaxisTitle("Normalized Mean Depth");
  graph.setYaxisTitle("GC content quantile", 0, 2);
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    for(unsigned int i=1; i <= 100; i++)
    {
      if(stats[idx].depthVsGC_norm[i]>0) {
        x.push_back(GC.gcContentVec[i]);        
        y.push_back(stats[idx].depthVsGC_norm[i]);
      } else {
        // y+="NA";
        // x.push_back(GC.gcContentVec[i]);        
        // y.push_back(0);
      }
    }
    // cumsum(x) / sum(x) # normalized GC content
    for (unsigned int i = 1; i < x.size() ; i++) {
      x[i] += x[i-1];
    }
    for (unsigned int i = 0; i < x.size(); i++) {
      x[i] /= x.back();
    }
    graph.addData(bamLabelArray[idx].c_str(), x, y);
  }
  
  graph.closePlot();


  graph.newPlot();
  graph.setTitle("Insert Size");
  graph.setXaxisTitle("Insert Size");
  graph.setYaxisTitle("Count (Million)");
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    std::map<int32_t, uint64_t>::iterator p;
    for(p=stats[idx].insertSize.begin(); p!=stats[idx].insertSize.end(); p++) {
      if (p->first > 800) continue;  // insert size too large, so skipping
      x.push_back(p->first);
      y.push_back(p->second);
    }
    graph.addData(bamLabelArray[idx].c_str(), x, y);
  }
  graph.closePlot();


  graph.newPlot();
  graph.setTitle("Q20 Base by Cycle");
  graph.setXaxisTitle("Cycle");
  graph.setYaxisTitle("Empirical Q20 Count (Million)");
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    for(int i=0; i<size; i++)
    {
      x.push_back(i+1);
      y.push_back(stats[idx].baseQ20CountByCycle[i]);
    }
    graph.addData(bamLabelArray[idx].c_str(), x, y);
  }
  graph.closePlot();

  graph.newPlot();
  graph.setTitle("Depth Distribution");
  graph.setXaxisTitle("Depth", 0, 200); // 
  graph.setYaxisTitle("Percentage of Covered Site");

  uint64_t sites = 0;
  if (regionIndicator.size()==0) {
    sites = referencegenome.sequenceLength();
  } else{
    for (unsigned int i = 0; i < regionIndicator.size() ; i++) {
      if (regionIndicator[i]) sites++;
    }
  }
  for (int idx = 0; idx < bamFiles.Length(); idx ++ ) {
    x.clear(); y.clear();
    uint64_t sumY = 0;
    std::map<int, uint64_t>::iterator p;
    for(p=stats[idx].depthDist.begin(); p!=stats[idx].depthDist.end(); p++) {
      x.push_back(p->first); // depth
      y.push_back(p->second);// freq
      sumY += p->second;
    }
    for (unsigned int yi = 1; yi < y.size(); ++yi) {
      y[yi] += y[yi-1];
    }
    for (unsigned int yi = 0; yi < y.size(); ++yi) {
      y[yi] = (sumY - y[yi]) / sites * 100;
    }
    std::ostringstream s;
    s << bamLabelArray[idx].c_str();
    s << " (No coverage = " << (1.0 - sumY / sites) * 100 << "%)";
    graph.addData(s.str().c_str(), x, y);
  }
  graph.closePlot();

  graph.newPlot();
  graph.setTitle("BAM Flagstat");
  graph.setXaxisTitle("Bam files");
  graph.setYaxisTitle("Read Count (Million)");
  std::vector<double> total, mapped, paired, properPaired, dup, qcFail;
  x.clear(); y.clear();
  const int m = 1000000;
  for (int i = 0; i < bamFiles.Length();  ++i ) {
    x.push_back(i+1);
    total.push_back(double(stats[i].nReads)/m);
    mapped.push_back(double(stats[i].nReads-stats[i].nUnMapped)/m);
    paired.push_back(double(stats[i].nPaired)/m);
    properPaired.push_back(double(stats[i].nProperPaired)/m);
    dup.push_back(double(stats[i].nDup)/m);
    qcFail.push_back(double(stats[i].nQCFail)/m);
  }
  graph.addData("Total", x, total);
  graph.addData("Mapped", x, mapped);
  graph.addData("Paired", x, paired);
  graph.addData("ProperPaired", x, properPaired);
  graph.addData("Duplicated", x, dup);
  graph.addData("QCFailed", x, qcFail);
  graph.closePlot();

  graph.newPlot();
  graph.setTitle("Mean Depth");
  graph.setXaxisTitle("Bam files");
  graph.setYaxisTitle("Depth");
  std::vector<double> meanDepth;
  x.clear(); y.clear();
  for (int i = 0; i < bamFiles.Length();  ++i ) {
    x.push_back(i+1);
    meanDepth.push_back(stats[i].coverage);
  }
  graph.addData("Mean Depth", x, meanDepth);
  graph.closePlot();

  graph.newPlot();
  graph.setTitle("Q20 Count");
  graph.setXaxisTitle("Bam files");
  graph.setYaxisTitle("Base Count (Million)");
  std::vector<double> q20Count;
  x.clear(); y.clear();
  for (int i = 0; i < bamFiles.Length();  ++i ) {
    x.push_back(i+1);
    q20Count.push_back(double(stats[i].nQ20)/1000000);
  }
  graph.addData("Q20 Count", x, q20Count);
  graph.closePlot();

  s = graph.dump();
  fputs(s.c_str(), fp);
  return;
}

void BamQC::Plot(String &plotFile, FILE *pf)
{
  if(pf==NULL) return;

  // Create legend text
  String legend, pchvec, s;
  StringArray bamLabelArray;
  if(bamLabel.Length()>0) bamLabelArray.ReplaceTokens(bamLabel, ",");

  legend+="legend.txt=c(";
  pchvec += "pchvec=c(";
  for(int i=0; i<bamFiles.Length(); i++){
    if(bamLabel.Length()==0){
      legend+=(i+1);
    }
    else {
      legend = legend + "'" +  bamLabelArray[i] + "'";
    }

    pchvec+=(i+1);

    if(i<(bamFiles.Length()-1))
    {
      legend+=",";
      pchvec+=",";
    }

  }
  legend += ");\n";
  legend += "lty.vec=c(1);\n";
  pchvec+=");\n";

  s = s +"NFiles=" +bamFiles.Length() + ";\ncolvec=c(1";
  for(int c=1; c<bamFiles.Length(); c++)
  {
    int t=c+1;
    s = s + "," + t;
  }
  s += ");\ngrid.col='gray';\n";
  s += pchvec;
  s = s + legend.c_str();
  s = s + "pdf(file=\"" +plotFile.c_str() + "\", height=12, width=12);\n";
  s += "par(mfrow=c(2,2)); par(cex.main=1.4); par(cex.lab=1.2); par(cex.axis=1.2);par(mar=c(5.1, 4.1, 4.1, 4.1))\n";

  s += "X=vector(\"list\", NFiles);\n";
  s += "Y=vector(\"list\", NFiles);\n";
  s += "Z=vector(\"list\", NFiles);\n";

  // Plot EPS vs reported Phred score
  s += GenRscript_EPSvsPhred_Plot();

  // Plot EPS vs cycle
  s += GenRscript_EPSvsCycle_Plot();

  // Plot depth vs GC content
  if(!noGC) s += GenRscript_DepthVsGC_Plot();

  s += GenRscript_InsertSize_Plot();

  //base Compositon by Cycle for bases [ACGTNO]
  // s += "par(mfrow=c(2,2)); par(cex.main=1.4); par(cex.lab=1.2); par(cex.axis=1.2);\n";
  // s += GenRscript_BaseComp_Plot();

  // Plot empirical Q20 base count per cycle
  s += GenRscript_Q20vsCycle_Plot();

  // Plot reported Q20 base count per cycle
  // s += GenRscript_ReportedQ20vsCycle_Plot();


  // Depth distribution
  if(page>1 && !noDepth) s += GenRscript_DepthDist_Plot();

  // Genearal stats about mapping
  if(page>1) s += GenRscript_GeneralStats_Plot();

  // Coverage and Q20 base count plot
  if(page>1) s += GenRscript_DepthCoverage_Q20_Plot();

  fprintf(pf, "%s\n", s.c_str());

  // Quit R and close pipe
  fprintf(pf, "q()\n");
  fclose(pf);
}

String BamQC::GenRscript_EPSvsPhred_Plot()
{
  String s;
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_EPSvsPhred_Data(i);
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_PhredDist_Data(i);

  s += "MAX.X=0; MAX.Y=0; MAX.Z=0;\n for(i in 1:NFiles){\nm.x=max(X[[i]]);\nif(length(Y[[i]])==1 & is.na(Y[[i]][1]) | length(which(!is.na(Y[[i]])))==0)m.y=NA else m.y=max(Y[[i]][which(!is.na(Y[[i]]))]);\nm.z=max(Z[[i]]);\nif(!is.na(m.x) & MAX.X<m.x) MAX.X=m.x;\nif(!is.na(m.y) & MAX.Y<m.y) MAX.Y=m.y;\nif(!is.na(m.z) & MAX.Z<m.z) MAX.Z=m.z;\n}\n";
  s = s + "plot(X[[1]],Y[[1]],xlab='Reported Phred', ylab='Empirical Phred', xlim=range(0, MAX.X*1.2), ylim=range(0, max(MAX.X,MAX.Y)), type='l',col=colvec[1], main='" + label+ " Empirical vs reported Phred score');\n";
  s += "if(NFiles>1)\n for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');\n";
  s += "points(x,x,col='purple', type='l');\n";
  s += "ratio = MAX.Z/20;\n";
  s += "for(i in 1:NFiles) {points(X[[i]][1:length(X[[i]])], Z[[i]][1:length(Z[[i]])]/ratio, col=colvec[i], type='l', lty=2);\n}\n";
  s += "legend(\"topright\",legend=legend.txt, col=colvec, lty=lty.vec);\n";
  //s += "grid(10, 10, col=grid.col);\n";
  s += "abline(v=pretty(seq(MAX.X*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(seq(MAX.Y), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "mtext(text=\"Base Count (M)\", side=4, line= 2.5, cex=par()$cex*1.2)\n";
  s += "axis.left.tick = pretty(seq(MAX.Y))\n";
  s += "axis.right.tick = axis.left.tick[axis.left.tick <= 20]\n";
  s += "axis.right.text = round(ratio * axis.right.tick, 1)\n";
  s += "axis(side = 4, at = axis.right.tick, labels= axis.right.text)\n";
  s += "\n";
  return(s);
}

String BamQC::GenRscript_EPSvsCycle_Plot()
{
  String s;
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_EPSvsCycle_Data(i);
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_CycleDist_Data(i);

  s += "MAX=0;MIN.Y=999999999; MAX.Z=0; \n for(i in 1:NFiles){\nif(length(which(!is.na(Y[[i]])))==0){m=NA; mm=NA;} else {m=max(Y[[i]][which(!is.na(Y[[i]]))]);mm=min(Y[[i]][which(!is.na(Y[[i]]))]);}; m.z=max(Z[[i]]); \n if(!is.na(m) & MAX<m) MAX=m; if(!is.na(mm) & MIN.Y>mm) MIN.Y=mm; if(MAX.Z<m.z) MAX.Z=m.z; \n}\n";
  s = s + "plot(X[[1]],Y[[1]], xlim=range(1, length(X[[1]])*1.2), ylim=range(0,MAX*1.2), xlab='Cycle', ylab='Empirical Phred', type='l',col=colvec[1], main='" + label + " Empirical Phred score by cycle');\n";
  s += "if(NFiles>1)\n for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');\n";
  s += "ratio = MIN.Y/MAX.Z;\n";
  s += "for(i in 1:NFiles) points(X[[i]], Z[[i]]*ratio/1.2, col=colvec[i], type='l', lty=2);\n";
  s += "legend(\"topright\",legend=legend.txt, col=colvec, lty=lty.vec);\n";
  //s += "grid(10, 10, col=grid.col);\n";
  s += "abline(v=pretty(range(1, length(X[[1]])*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(seq(MAX.Y), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "mtext(text=\"Read Count (M)\", side=4, line= 2.5, cex=par()$cex*1.2)\n";
  s += "axis.left.tick = pretty(seq(MAX.Y))\n";
  s += "axis.right.tick = axis.left.tick[axis.left.tick <= 20]\n";
  s += "axis.right.text = round(ratio * axis.right.tick, 1)\n";
  s += "axis(side = 4, at = axis.right.tick, labels= axis.right.text)\n";
  s += "\n";

  return(s);
}

String BamQC::GenRscript_Q20vsCycle_Plot()
{
  String s;
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_Q20vsCycle_Data(i);
  s += "MAX=0;MIN.Y=999999999; MAX.Z=0; \n for(i in 1:NFiles){\nif(length(which(!is.na(Y[[i]])))==0){m=NA; mm=NA;} else {m=max(Y[[i]][which(!is.na(Y[[i]]))]);mm=min(Y[[i]][which(!is.na(Y[[i]]))]);}; m.z=max(Z[[i]]); \n if(!is.na(m) & MAX<m) MAX=m; if(!is.na(mm) & MIN.Y>mm) MIN.Y=mm; if(MAX.Z<m.z) MAX.Z=m.z; \n}\n";
  s = s + "plot(X[[1]],Y[[1]], xlim=range(1, length(X[[1]])*1.2), ylim=range(0,MAX*1.2), xlab='Cycle', ylab='Empirical Q20 base count', type='l',col=colvec[1], main='" + label + " Empirical Q20 base count by cycle');\n";
  s += "if(NFiles>1)\n for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');\n";
  s += "legend(\"topright\",legend=legend.txt, col=colvec, lty=lty.vec);\n";
  //s += "grid(10, 10, col=grid.col);\n";
  s += "abline(v=pretty(range(1, length(X[[1]])*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(range(0,MAX*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "\n";

  return(s);
}

String BamQC::GenRscript_ReportedQ20vsCycle_Plot()
{
  String s;
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_ReportedQ20vsCycle_Data(i);
  s += "MAX=0;MIN.Y=999999999; MAX.Z=0; \n for(i in 1:NFiles){\nif(length(which(!is.na(Y[[i]])))==0){m=NA; mm=NA;} else {m=max(Y[[i]][which(!is.na(Y[[i]]))]);mm=min(Y[[i]][which(!is.na(Y[[i]]))]);}; m.z=max(Z[[i]]); \n if(!is.na(m) & MAX<m) MAX=m; if(!is.na(mm) & MIN.Y>mm) MIN.Y=mm; if(MAX.Z<m.z) MAX.Z=m.z; \n}\n";
  s = s + "plot(X[[1]],Y[[1]], xlim=range(1, length(X[[1]])*1.2), ylim=range(0,MAX*1.2), xlab='Cycle', ylab='Reported Q20 base count', type='l',col=colvec[1], main='" + label + " Reported Q20 base count by cycle');\n";
  s += "if(NFiles>1)\n for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');\n";
  s += "legend(\"topright\",legend=legend.txt, col=colvec, lty=lty.vec);\n";
  //s += "grid(10, 10, col=grid.col);\n";
  s += "abline(v=pretty(range(1, length(X[[1]])*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(seq(MAX.Y), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "mtext(text=\"Read Count (M)\", side=4, line= 2.5, cex=par()$cex*1.2)\n";
  s += "axis.left.tick = pretty(seq(MAX.Y))\n";
  s += "axis.right.tick = axis.left.tick[axis.left.tick <= 20]\n";
  s += "axis.right.text = round(ratio * axis.right.tick, 1)\n";
  s += "axis(side = 4, at = axis.right.tick, labels= axis.right.text)\n";
  s += "\n";

  return(s);
}

String BamQC::GenRscript_DepthVsGC_Plot()
{
  String s="";
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_DepthVsGC_Data(i);

  s += "MAX=0;\n for(i in 1:NFiles){\n x=X[[i]][20:80];\n y=Y[[i]][20:80]; \nif(length(which(!is.na(y)))==0)m=NA else m=max(y[which(!is.na(y))]);\nif(!is.na(m) & MAX<m) MAX=m;\n}\n";
  s += "mm=vector(); mat=vector();\nfor(i in 1:NFiles) mat = rbind(mat, Y[[i]]);\nmm=sapply(data.frame(mat), min);\n";
  s = s + "plot(X[[1]],Y[[1]], xlim=range(0,120), ylim=range(0,MAX*1.2), xlab='GC content', ylab='Normalized mean depth', type='l', col=colvec[1], main='" + label+ " Mean depth vs. GC');\n";
  s += "if(NFiles>1) \n for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], type='l');\nabline(h=1.0, col='red', lty=2);\n";
  s += "zz = (z/1000)/(sum(z/1000));\n";
  s += "mm.r = mm/zz; mm.r.mid = mm.r[20:80]; if(length(which(!is.na(mm.r.mid)))==0)min.r=NA else min.r = min(mm.r.mid[!is.na(mm.r.mid)]); \n z = zz*max(2,(min.r*0.5)); \n";
  s +=  "points(X[[1]], z, type='h', col='purple');\n";
  s += "legend(\"topright\", legend=legend.txt, col=colvec, lty=lty.vec);\n";
  //s += "grid(10, 10, col=grid.col);\n";
  s += "abline(v=pretty(range(0,120), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(range(0,MAX*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  // s += "mtext(text=\"Read Count (M)\", side=4, line= 2.5, cex=par()$cex*1.2)\n";
  // s += "axis.left.tick = pretty(seq(MAX*1.2))\n";
  // s += "axis.right.tick = axis.left.tick[axis.left.tick <= 20]\n";
  // s += "axis.right.text = round(ratio * axis.right.tick, 1)\n";
  // s += "axis(side = 4, at = axis.right.tick, labels= axis.right.text)\n";
  s += "\n";

  return(s);
}

String BamQC::GenRscript_DepthDist_Plot()
{
  String s="";
  for(int i=0; i<bamFiles.Length(); i++)
  {
    s += GenRscript_DepthDist_Data(i);
  }

  // total site
  char temp[100];
  uint64_t sites = 0;
  if (regionIndicator.size()==0) {
    sites = referencegenome.sequenceLength();
  } else{
    for (unsigned int i = 0; i < regionIndicator.size() ; i++) {
      if (regionIndicator[i]) sites++;
    }
  }
  sprintf(temp, "%lu", sites);
  s += "total.site = ";
  s += temp;
  s += "\n";

  // make depth.legend.txt
  s += "depth.legend.txt = legend.txt\n";
  s += "for(i in 1:NFiles){";
  s += "depth.legend.txt[i] = paste(legend.txt[i], '  (No coverage = ',round((1-sum(Y[[i]])/total.site)*100,2), '% )'); ";
  s += "Y[[i]]=(sum(Y[[i]]) - cumsum(Y[[i]]))/total.site * 100; ";
  s += "}\n";

  s += "MAX.X=0; MAX.Y=0; \nfor(i in 1:NFiles){\n tmp = length(which(Y[[i]] > max(Y[[i]])*0.6)) ; \n if (tmp < 10) tmp = 10; \n if (MAX.X < tmp) MAX.X = tmp; \n if (MAX.Y < max(Y[[i]])) MAX.Y = max(Y[[i]]); }\n";
  s = s + "plot(X[[1]],Y[[1]], xlim=range(1, MAX.X), ylim=range(0,MAX.Y*1.2), xlab='Depth', ylab='Percentage of covered sites', pch = '+', type='b', col=colvec[1], main='" + label + " Depth distribution');\n";
  s += "if(NFiles>1) \n for(i in 2:NFiles) points(X[[i]], Y[[i]], col=colvec[i], pch = '+', type='b');\n";
  s += "legend(\"topright\",legend=depth.legend.txt, col=colvec, lty=lty.vec);\n";
  // s += "grid(10,10, col=grid.col);\n";
  s += "abline(v=pretty(range(0,MAX.X), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(range(0,MAX.Y*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "\n";
  return(s);
}

String BamQC::GenRscript_InsertSize_Plot()
{
  String s="";
  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_InsertSize_Data(i);

  s += "MAX.X=0; MAX.Y=0; MIN.X=999999999; \n for(i in 1:NFiles){\nif(is.na(X[[i]][1])) next; \n x=X[[i]];\n y=Y[[i]]; \n m.y=max(y[which(!is.na(y))]);\n if(MAX.Y<m.y) MAX.Y=m.y;\n m.x=x[which(y==m.y)[1]];\n if(MAX.X<m.x) MAX.X=m.x;\n if(MIN.X>m.x) MIN.X=m.x;\n }\n";
  s = s + "plot(X[[1]],Y[[1]]/1000000, xlim=range(MIN.X-150, MAX.X+150), ylim=range(0,MAX.Y/1000000*1.2), xlab='Insert size', ylab='Count in million', type='l', col=colvec[1], main='" + label + " Insert size distribution');\n";
  s += "if(NFiles>1) \n for(i in 2:NFiles) points(X[[i]], Y[[i]]/1000000, col=colvec[i], type='l');\n";
  s += "legend(\"topright\",legend=legend.txt, col=colvec, lty=lty.vec);\n";
  //s += "grid(10,10, col=grid.col);\n";
  s += "abline(v=pretty(range(MIN.X-150, MAX.X+150), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(range(0,MAX.Y/1000000*1.2), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "\n";
  return(s);
}

String BamQC::GenRscript_DepthCoverage_Q20_Plot()
{
  StringArray bamLabelArray;
  bamLabelArray.ReplaceTokens(bamLabel, ",");
  String s, names_arg;
  s+="x1=c(";
  names_arg +="c(";
  for(int i=0; i<bamFiles.Length(); i++)
  {
    s += stats[i].coverage;
    if(bamLabel.Length()>0) names_arg = names_arg + "'" +  bamLabelArray[i] + "'";
    else names_arg+=(i+1);
    if(i<(bamFiles.Length()-1)){
      s+=",";
      names_arg+=",";
    }
  }
  s+=");\n";
  names_arg+=")";

  s+="x2=c(";
  for(int i=0; i<bamFiles.Length(); i++)
  {
    s+=double(stats[i].nQ20)/1000000;
    if(i<(bamFiles.Length()-1)){
      s+=",";
    }
  }
  s+=");\n";

  s += "ratio = max(x2)/max(x1);\n";
  s += "if (ratio > 5 || (ratio < 1/5 && ratio >= 1e-10)) {;\n";
  s += "x2 = x2 / ratio;\n";
  s += "} else {;\n";
  s += "ratio = 1;\n";
  s += "};\n";
  s += "ylim = range(-max(x2), max(x1)) * 1.2;\n";
  s += "y1lim = range(0, max(x1)) * 1.2;\n";
  s += "y2lim = range(-max(x2), 0) * 1.2;\n";
  s += "barplot(x1, ylim= ylim, axes = F, names.arg=" + names_arg + ", xlab=\'Bam file index\', col=\'light blue\', main='" + label + "\\nMean depth of sequencing / Empirical Q20 count\');\n";
  s += "barplot(-x2, ylim= ylim, axes = F, add = T, col = \'light pink\');\n";

  s += "tick.pos = pretty(y1lim);\n";
  s += "tick.text = as.character(pretty(y1lim));\n";
  s += "tick.text[1] = NA;\n";
  s += "axis(side = 2, at = tick.pos, labels = tick.text );\n";
  s += "abline(h=tick.pos, lty=\"dotted\", col = \"lightgray\");\n";

  s += "tick.pos = pretty(y2lim*ratio)/ratio;\n";
  s += "axis(side = 2, at = tick.pos, labels= as.character(-pretty(y2lim*ratio)));\n";
  s += "abline(h=tick.pos, lty=\"dotted\", col = \"lightgray\");\n";

  s += "mtext(side = 2, \'Mean depth\', adj = 1, line = 3, cex = par()$cex * 1.2);\n";
  s += "mtext(side = 2, \'Q20 count in million\', adj = 0, line = 3, cex = par()$cex * 1.2);\n";

  // s = s + "barplot(x, names.arg="+names_arg+", ylim=range(0, max(x)), xlab='Bam file index', ylab='Mean depth', col='light blue', main='" + label + " Mean depth of sequencing');\n";
  return(s);
}

String BamQC::GenRscript_GeneralStats_Plot()
{
  String leg = "legend.txt=c('Total', 'Mapped', 'Paired', 'ProperPair','Dup', 'QCFail');\n";
  StringArray bamLabelArray;
  bamLabelArray.ReplaceTokens(bamLabel, ",");
  int m = 1000000;
  String x, y, z, u, v, w, labelvec;
  x = "x=c("; y="y=c("; z="z=c("; u="u=c("; v="v=c(";w="w=c("; labelvec="labelvec=c(";
  for(int i=0; i<bamFiles.Length(); i++)
  {
    if(bamLabel.Length()>0) labelvec = labelvec + "'" + bamLabelArray[i] + "'";
    else labelvec += (i+1);
    x += double(stats[i].nReads)/m;
    y += double(stats[i].nReads-stats[i].nUnMapped)/m;
    z += double(stats[i].nPaired)/m;
    u += double(stats[i].nProperPaired)/m;
    v += double(stats[i].nDup)/m;
    w += double(stats[i].nQCFail)/m;

    if(i<bamFiles.Length()-1)
    {
      labelvec += ",";
      x += ","; y += ","; z += ",";
      u += ","; v += ","; w += ",";
    }
  }
  x += ");\n"; y+=");\n"; z += ");\n"; u+=");\n"; v+=");\n"; w+=");\n"; labelvec += ");\n";

  String s;
  s = s + labelvec + leg + x + y + z + u + v + w;
  s += "pchvec=c(1,2,3,4,5,6); colvec=c(1,2,3,4,5,6);\n";
  s = s+ "plot(x, xlab='Bam file index', ylab='Read count in million', ylim=range(0, max(x)*1.4), main='" + label + " Flag stats', pch=pchvec[1],col=colvec[1], type='b', axes=F);\n";
  s += "points(y, pch=pchvec[2], col=colvec[2], type='b');\n";
  s += "points(z, pch=pchvec[3], col=colvec[3], type='b');\n";
  s += "points(u, pch=pchvec[4], col=colvec[4], type='b');\n";
  s += "points(v, pch=pchvec[5], col=colvec[5], type='b');\n";
  s += "points(w, pch=pchvec[6], col=colvec[6], type='b');\n";
  s += "axis(side=1, at=c(1:length(x)), labels=labelvec);\n";
  s += "axis(side=2);\nbox(); \n";
  ///s += "grid(10,10,col=grid.col); \n";
  s += "legend(\"topleft\", legend=legend.txt, col=c(1,2,3,4,5,6), lty=1, pch=pchvec, merge=TRUE, horiz=F,cex=0.9);\n";
  s += "abline(v=seq(x), lty=\"dotted\", col = \"lightgray\")\n";
  s += "abline(h=pretty(seq(0, max(x)*1.4), n= 10), lty=\"dotted\", col = \"lightgray\")\n";
  s += "\n";

  return(s);
}

// Not yet finished
String BamQC::GenRscript_BaseComp_Plot()
{
  String s = "data=vector(\"list\");\n";

  for(int i=0; i<bamFiles.Length(); i++)
    s += GenRscript_BaseComp_Data(i);

  s = s+"for(i in 1:"+bamFiles.Length()+") {\n";
  s += " T = sapply(data.frame(data[[i]]), sum);\n";
  s += " for(j in 1:5){\n";
  s += "  data[[i]][j,] = data[[i]][j,]/T;\n";
  s += "   if(i==1)\n plot(data[[i]][j,], col=colvec[i], type='l') ";
  s += "   else points(data[[i]][j,], col=colvec[i],type='l');\n";
  s += "  }\n}\n";

  return(s);
}

String BamQC::GenRscript_EPSvsPhred_Data(int idx)
{
  int Ridx = idx+1;
  String x("x = c(");
  String y("y = c(");
  for(unsigned int i=0; i<stats[idx].qual.size(); i++)
  {
    x+=stats[idx].qual[i];
    if(stats[idx].misMatchRateByQual[stats[idx].qual[i]]==0)
      y+=MAXQ;
    else
      y+=double(-10*log10(stats[idx].misMatchRateByQual[stats[idx].qual[i]]));
    if(i<(stats[idx].qual.size()-1)) { x+=","; y+="," ;}
  }
  x+=");\n";
  y+=");\n";

  String s = x+y;
  s = s+"if(length(x)==0) x = NA; X[["+Ridx+"]] = x;\n";
  s = s+"if(length(y)==0) y = NA; Y[["+Ridx+"]] = y;\n";

  return(s);
}

String BamQC::GenRscript_PhredDist_Data(int idx)
{
  vector<int> q = stats[idx].qual;
  int Ridx = idx+1;
  String z = "z = c(";
  for(unsigned int i=0; i<stats[idx].qual.size(); i++)
  {
    z += double(stats[idx].qualCount[q[i]])/1000000;
    if(i<(stats[idx].qual.size()-1)) { z+="," ;}
  }
  z+=");\n";
  //  z += "z=z/sum(z);\n";
  z = z+"if(length(z)==0) z = NA; Z[["+Ridx+"]] = z;\n";

  return(z);
}

String BamQC::GenRscript_EPSvsCycle_Data(int idx)
{
  int Ridx = idx+1;
  String x = "x = c(";
  String y = "y = c(";
  for(int i=0; i<size; i++)
  {
    x+=(i+1);
    if(stats[idx].misMatchRateByCycle[i]==-1)
      y+="NA";
    else if(stats[idx].misMatchRateByCycle[i]==0)
      y += MAXQ;
    else
      y+=double(-10*log10(stats[idx].misMatchRateByCycle[i]));
    if(i<(size-1)) { x+=","; y+="," ;}
  }
  x+=");\n";
  y+=");\n";

  String s = x+y;
  s = s+"X[["+Ridx+"]] = x;\n";
  s = s+"Y[["+Ridx+"]] = y;\n";

  return(s);
}

String BamQC::GenRscript_Q20vsCycle_Data(int idx)
{
  int Ridx = idx+1;
  String x = "x = c(";
  String y = "y = c(";
  for(int i=0; i<size; i++)
  {
    x += (i+1);
    String sUInt64;
    sUInt64.printf("%llu", stats[idx].baseQ20CountByCycle[i]);
    y += sUInt64;
    if(i<(size-1)) { x+=","; y+="," ;}
  }
  x+=");\n";
  y+=");\n";

  String s = x+y;
  s = s+"X[["+Ridx+"]] = x;\n";
  s = s+"Y[["+Ridx+"]] = y;\n";

  return(s);
}

String BamQC::GenRscript_ReportedQ20vsCycle_Data(int idx)
{
  int Ridx = idx+1;
  String x = "x = c(";
  String y = "y = c(";
  for(int i=0; i<size; i++)
  {
    x += (i+1);
    String sUInt64;
    sUInt64.printf("%llu", stats[idx].baseReportedQ20CountByCycle[i]);
    y += sUInt64;
    if(i<(size-1)) { x+=","; y+="," ;}
  }
  x+=");\n";
  y+=");\n";

  String s = x+y;
  s = s+"X[["+Ridx+"]] = x;\n";
  s = s+"Y[["+Ridx+"]] = y;\n";

  return(s);
}

String BamQC::GenRscript_CycleDist_Data(int idx)
{
  int Ridx = idx+1;
  String z = "z = c(";
  for(int i=1; i<=size; i++)
  {
    String sDouble;
    sDouble.printf("%llu", stats[idx].cycles[i]);
    z += sDouble;
    if(i<size) { z+="," ;}
  }
  z+=");\n";
  z = z + "Z[[" + Ridx + "]] = z/1000000;\n";
  return(z);
}

String BamQC::GenRscript_DepthVsGC_Data(int idx)
{
  int Ridx = idx+1;
  String x = "x = c(";
  String y = "y = c(";
  String z = "z = c(";
  for(int i=1; i<=100; i++)
  {
    x+=i;
    if(stats[idx].depthVsGC_norm[i]>0)
      y+=stats[idx].depthVsGC_norm[i];
    else
      y+="NA";

    // Constrcut data z for GC content
    if(Ridx==1)
      z+=GC.gcContentVec[i];
    if(i<100 && Ridx==1) z+=",";

    if(i<100) { x+=","; y+=",";}
  }
  x+=");\n";
  y+=");\n";
  z+=");\n";

  String s;
  if(Ridx==1) s += z;
  s = s + x+y;
  s = s+"X[["+Ridx+"]] = x;\n";
  s = s+"Y[["+Ridx+"]] = y;\n";

  return(s);
}


String BamQC::GenRscript_DepthDist_Data(int idx)
{
  int Ridx = idx+1;

  std::vector<int> depthVec;
  std::vector<uint64_t> depthFreq;

  String x("x = c(");
  String y("y = c(");

  std::map<int, uint64_t>::iterator p;
  for(p=stats[idx].depthDist.begin(); p!=stats[idx].depthDist.end(); p++) {
    depthVec.push_back(p->first);
    depthFreq.push_back(p->second);
  }

  for(unsigned int i=0; i<depthVec.size(); i++){
    x+=depthVec[i];
    String sDouble;
    sDouble.printf("%llu", depthFreq[i]);
    y+=sDouble;
    if(i<depthVec.size()-1)
    {
      x+=",";
      y+=",";
    }
  }
  x+=");\n";
  y+=");\n";

  String s = x+y;
  s = s+"X[["+Ridx+"]] = x;\n";
  s = s+"Y[["+Ridx+"]] = y;\n";

  return(s);
}

// Not finished yet
String BamQC::GenRscript_BaseComp_Data(int idx)
{
  int Ridx = idx+1;
  int entries = 6*size;
  String s;
  s = s+"m=matrix(rep(0,"+entries+"), c(6,"+size+"));\n";

  for(int i=1; i<=6; i++)
  {
    s = s+"m["+i+",]=c(";
    for(int j=0; j<size; j++){
      s += double(stats[idx].baseCountByCycle[j][i-1])/1000000;
      if(j<(size-1))
        s+=",";
    }
    s+=");\n";
  }
  s = s+"data[["+Ridx+"]]=m;\n";

  return(s);
}

String BamQC::GenRscript_InsertSize_Data(int idx)
{
  int Ridx = idx+1;

  std::vector<int32_t> insertVec;
  std::vector<uint64_t> insertFreq;

  String x = "x = c(";
  String y = "y = c(";

  std::map<int32_t, uint64_t>::iterator p;
  for(p=stats[idx].insertSize.begin(); p!=stats[idx].insertSize.end(); p++) {
    insertVec.push_back(p->first);
    insertFreq.push_back(p->second);
  }

  for(unsigned int i=0; i<insertVec.size(); i++){
    x+=insertVec[i];
    String sDouble;
    sDouble.printf("%llu", insertFreq[i]);
    y+=sDouble;
    if(i<insertVec.size()-1)
    {
      x+=",";
      y+=",";
    }
  }
  x+=");\n";
  y+=");\n";

  String s;
  s += x;
  s += y;
  s += "if(length(x)==0) x=NA; if(length(y)==0) y=NA;\n";
  s = s+"X[[" + Ridx + "]] = x;\n";
  s = s+"Y[[" + Ridx + "]] = y;\n";

  return(s);
}
