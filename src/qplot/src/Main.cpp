#include "QCStats.h"
#include "BamQC.h"

#include "Parameters.h"

#include <sys/stat.h>
bool fileExists(const char* path) {
  struct stat sts;
  if ((stat (path, &sts)) == -1)
  {
    return false; //printf ("The file %s doesn't exist...\n", argv [1]);
  } else {
    return true;
  }
}

void stripSuffix(const char* suffix, String* fn) {
  String s1 = suffix;
  String s2 = *fn;
  if (s1.Length() > s2.Length()) // suffix is longer
    return;

  String s3 = s2.Right(s1.Length());
  if (s1 == s3) { // match suffix
    *fn = s2.Left(s2.Length() - s1.Length());
  } else {
    return;
  }
}

/**
 * strip suffix from @param reference
 * e.g. strip hg19.fa, hg19.fa.gz, hg19.fa.bgz or hg19.fasta, hg19.fasta.gz, hg19.fasta.bgz
 * to hg19
 */
String getReferenceGenomeBasename(const String& reference) {
  String ret = reference;
  stripSuffix(".gz", &ret);
  stripSuffix(".bgz", &ret);
  stripSuffix(".fasta", &ret);
  stripSuffix(".fa", &ret);
  return ret;
}

int main(int argc, char *argv[])
{
  bool unpaired = false;
  bool read1 = false;
  bool read2 = false;
  bool paired = false;
  bool keepDup = false;
  bool keepQCFail = false;
  double minMapQuality = 0;
  int nRecords = -1;

  String reference = "/net/fantasia/home/zhanxw/software/qplot/data/human.g1k.v37.fa";
  String dbSNPFile = "/net/fantasia/home/zhanxw/software/qplot/data/dbSNP130.UCSC.coordinates.tbl";
  String gcContentFile = ""; // default GC content file /net/fantasia/home/zhanxw/software/qplot/data/human.g1k.w100.gc";
  bool createGCContentFile = false; // not create GC file on the fly.
  String regions;
  bool invertRegion = false; // by default, not invert regionIndicator
  String gcContentFile_create;
  int windowSize = 100;

  ParameterList pl;

  String statsFile;
  String plotFile;
  String RcodeFile;
  String xmlFile;
  String label;
  String bamLabel;
  String lanes;
  String readGroup;

  const bool noGC = false;
  bool noDepth = false;
  bool noeof = false;
  int page = 2;

  BEGIN_LONG_PARAMETERS(longParameters)
      LONG_PARAMETER_GROUP("References")
      LONG_STRINGPARAMETER("reference",&reference)
      LONG_STRINGPARAMETER("dbsnp", &dbSNPFile)
      LONG_PARAMETER_GROUP("GC content file options")
      LONG_INTPARAMETER("winsize", &windowSize)
      LONG_PARAMETER_GROUP("Region list")
      LONG_STRINGPARAMETER("regions", &regions)
      EXCLUSIVE_PARAMETER("invertRegion", &invertRegion)
      LONG_PARAMETER_GROUP("Flag filters")
      LONG_PARAMETER("read1_skip", &read1)
      LONG_PARAMETER("read2_skip", &read2)
      LONG_PARAMETER("paired_skip", &paired)
      LONG_PARAMETER("unpaired_skip", &unpaired)
      LONG_PARAMETER_GROUP("Dup and QCFail")
      LONG_PARAMETER("dup_keep", &keepDup)
      LONG_PARAMETER("qcfail_keep", &keepQCFail)
      LONG_PARAMETER_GROUP("Mapping filters")
      LONG_DOUBLEPARAMETER("minMapQuality", &minMapQuality)
      LONG_PARAMETER_GROUP("Records to process")
      LONG_INTPARAMETER("first_n_record", &nRecords)
      LONG_PARAMETER_GROUP("Lanes to process")
      LONG_STRINGPARAMETER("lanes", &lanes)
      LONG_PARAMETER_GROUP("Read group to process")
      LONG_STRINGPARAMETER("readGroup", &readGroup)
      LONG_PARAMETER_GROUP("Input file options")
      LONG_PARAMETER("noeof", &noeof)
      LONG_PARAMETER_GROUP("Output files")
      LONG_STRINGPARAMETER("plot", &plotFile)
      LONG_STRINGPARAMETER("stats", &statsFile)
      LONG_STRINGPARAMETER("Rcode", &RcodeFile)
      LONG_STRINGPARAMETER("xml", &xmlFile)
      LONG_PARAMETER_GROUP("Plot labels")
      LONG_STRINGPARAMETER("label", &label)
      LONG_STRINGPARAMETER("bamLabel", &bamLabel)
      LONG_PARAMETER_GROUP("Obsoleted (DO NOT USE)")
      LONG_STRINGPARAMETER("gccontent", &gcContentFile)
      EXCLUSIVE_PARAMETER("create_gc",&createGCContentFile)
      END_LONG_PARAMETERS();

  pl.Add(new LongParameters("\n", longParameters));

  StringArray bamFiles;

  int in = pl.ReadWithTrailer(argc, argv, 1);
  for (int i=in+1; i<argc; i++){
    bamFiles.Push(argv[i]);
  }

  pl.Status();

#define QPLOT_VERSION 20130619
  fprintf(stderr, "QPLOT (Ver: %d) started.\n", QPLOT_VERSION);
  fprintf(stderr, "QPLOT Documentation: http://genome.sph.umich.edu/wiki/QPLOT\n");
  fprintf(stderr, "\n");
  
  // if(bamFiles.Length()==0)
  //   fprintf(stderr, "No SAM/BAM files provided and no QPLOT outputs!\n");
  
  if(reference.Length()==0)
    error("Reference not provided!\n");

  if (gcContentFile.Length()) {
    fprintf(stderr, "--gccontent is obselete, now GC content files is automaticall determined.\n");
    fprintf(stderr, "see http://genome.sph.umich.edu/wiki/QPLOT for details\n");
    exit(1);
  }
  if (createGCContentFile) {
    fprintf(stderr, "--create_gc is obselete, now creating GC content files is automaticall determined.\n");
    fprintf(stderr, "see http://genome.sph.umich.edu/wiki/QPLOT for details\n");
    exit(1);
  }
  
  // determine GC content file name
  fprintf(stderr, "Reference genome file [ %s ] is used.\n", reference.c_str());
  String referenceGenomeBase = getReferenceGenomeBasename(reference);
  if (windowSize <= 0) {
    error("Please specify a positive number for window size!\n");
  }
  gcContentFile.printf("%s.winsize%d.gc",
                       referenceGenomeBase.c_str(),
                       windowSize);
  fprintf(stderr, "GC content file [ %s ] is used for window size %d.\n", gcContentFile.c_str(), windowSize);
                       
  // check if GC content file exists
  if (!fileExists(gcContentFile)) {
    // create GC content file
    FILE* fp = fopen(gcContentFile.c_str(), "wb");
    if (fp == NULL) {
      fprintf(stderr, "Cannot create GC content file [ %s ]\n", gcContentFile.c_str());
      error("Fatal error: GC file create failed\n\n");
    } else {
      fclose(fp);
    }
    GCContent GC;
    fprintf(stderr, "Creating GC content file...\n");
    GC.OutputGCContent(reference, windowSize, gcContentFile, regions, invertRegion);
    fprintf(stderr, "GC content file [ %s ] created.\n", gcContentFile.c_str());
  }

  if(regions.Length() == 0 && invertRegion) {
    error("Need to specify --regions whenusing --invertRegion");
  }

  if(bamFiles.Length()==0)
    error("No SAM/BAM files provided, stopped!\n");
  
  fprintf(stderr, "The following files are to be processed...\n\n");
  for(int i=0; i<bamFiles.Length();i++)
    fprintf(stderr, "%s\n", bamFiles[i].c_str());
  fprintf(stderr, "\n");

  if(plotFile.Length()==0)
    warning("No plot will be generated!\n");

  if(bamLabel.Length()>0) {
    StringArray bamLabelArray;
    bamLabelArray.ReplaceTokens(bamLabel, ",");
    if(bamLabelArray.Length()<bamFiles.Length())
      error("BAM/SAM file number larger than lable number!\n");
    if(bamLabelArray.Length()>bamFiles.Length())
      warning("BAM/SAM file number smaller than lable number and extra lables ignored!\n");
  }

  FILE *RCODE=NULL;  // .R file
  FILE *pf = NULL;   // pipe to Rscript
  FILE *STATSFH = NULL;  // .stat file

  if(RcodeFile.Length()>0){
    RCODE = fopen(RcodeFile.c_str(), "w");
    if(RCODE==NULL)
      error("Open Rcode file for output failed!\n", RcodeFile.c_str());
  }

  if(plotFile.Length()>0)
  {
    pf = popen("Rscript --vanilla -", "w");
    if(pf==NULL)
      error("Open Rscript failed!\n", plotFile.c_str());
  }

  if(statsFile.Length()>0)
  {
    STATSFH = fopen(statsFile.c_str(), "w");
    if(STATSFH==NULL)
      error("Open stats file %s failed!\n", statsFile.c_str());
    fclose(STATSFH);
  }

  QSamFlag filter;

  if(paired && unpaired)
    warning("The filter --unpaired overrides --paired\n");

  if(unpaired) paired=true;
  filter.SetRead1(read1);
  filter.SetRead2(read2);
  filter.SetPaired(paired);
  filter.SetUnPaired(unpaired);
  filter.SetDuplicate(!keepDup);
  filter.SetQCFail(!keepQCFail);

  BamQC qc(bamFiles);
  if (noeof) {
    qc.SkipCheckEof();
  };

  qc.noGC = noGC;
  qc.noDepth = noDepth;
  qc.page = page;

  qc.SetLanes2Process(lanes);
  qc.SetReadGroup2Process(readGroup);
  qc.SetNumRecords2Process(nRecords);
  qc.SetGCInputFile(gcContentFile);
  qc.SetLabel(label);
  qc.SetBamLabels(bamLabel);
  qc.LoadGenomeSequence(reference);
  qc.LoadRegions(regions, invertRegion);
  qc.LoaddbSNP(dbSNPFile);
  qc.CalculateQCStats(filter, minMapQuality);
  qc.OutputStats(statsFile);

  if(RcodeFile.Length()>0){
    if (plotFile.Length() > 0 ) {
      qc.Plot(plotFile, RCODE);
    } else {
      // make a default pdf file
      String defaultPlotFile = RcodeFile;
      stripSuffix(".R", &defaultPlotFile);
      defaultPlotFile += ".pdf";
      qc.Plot(defaultPlotFile, RCODE);
    }
  }

  if(plotFile.Length()>0)
  {
    qc.Plot(plotFile, pf);
  }

  if (xmlFile.Length() > 0) {
    FILE* fXml = fopen(xmlFile.c_str(), "wt");
    qc.OutputXML(fXml);
    fclose(fXml);
  }

  return(0);

} //END of main
