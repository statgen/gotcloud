// ***************************************************************************
// main.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 9 August 2012 (DB)
// ---------------------------------------------------------------------------
// Main entry point for the Premo app.
// ***************************************************************************

#include "options.h"
#include "premo.h"
#include "premo_settings.h"
#include "premo_version.h"
#include <iostream>
#include <string>
using namespace std;

static
void printVersion(void) {

    cerr << endl
         << "------------------------------" << endl
         << "premo v" << PREMO_VERSION_MAJOR << "." << PREMO_VERSION_MINOR << "." << PREMO_VERSION_BUILD << endl
         << "(c) 2012 Derek Barnett" << endl
         << "Boston College, Biology Dept." << endl
         << "------------------------------" << endl
         << endl;
}

int main(int argc, char* argv[]) {

    // -------------------------------------------------------
    // command line parameters & help info
    // -------------------------------------------------------

    // set program details
    const string name("premo");
    const string description("\"pre-Mosaik\" application that generates MosaikAligner parameters "
                             "for either single-end or paired-end sequencing data. For paired-end "
                             "data, Premo uses a bootstrapping heuristic to estimate the overall "
                             "read length & fragment length, running Mosaik on samples from the "
                             "input until it sees convergence on both of these values. For single-"
                             "end data, the heuristic Mosaik batch runs are not needed (there is no "
                             "fragment length to calculate), and only the read length is determined. "
                             "The resulting Mosaik parameters, reported in JSON format, should allow "
                             "Mosaik to perform well on the full input dataset.\n"
                             "Note - Mosaik does not support this output file directly, but the "
                             "file can be parsed and used to generate a reasonable Mosaik command "
                             "line.");
    const string usage("-fq1 <file> -out <file> -st <technology> [options]");
    Options::SetProgramInfo(name, description, usage);

    // hook up command-line options to our settings structure
    PremoSettings settings;

    OptionGroup* IO_Opts = Options::CreateOptionGroup("Input & Output");

    const string annpe("neural network filename (paired-end) - required for paired-end data");
    const string annse("neural network filename (single-end) - required for paired-end data");
    const string fq1("input FASTQ file (mate 1 or single-end)");
    const string fq2("input FASTQ file (mate 2) - required for paired-end data");
    const string jump("stub for jump database files  - required for paired-end data");
    const string keep("keep generated files (auto-deleted by default)");
    const string mosaik("/path/to/Mosaik/bin  - required for paired-end data");
    const string out("output file (JSON). Contains generated Mosaik parameters & raw batch results");
    const string ref("MosaikBuild-generated reference archive  - required for paired-end data");
    const string singleEnd("run Premo in single-end data mode. By default, Premo assumes paired-end data.");
    const string tmp("scratch directory for any generated files - only used for paired-end data");
    const string verbose("verbose output (to stderr)");
    const string version("show version information");

    const string FN("filename");
    const string DIR("directory");

    Options::AddValueOption("-annpe",  FN,  annpe,  "", settings.HasAnnPeFilename,     settings.AnnPeFilename,     IO_Opts);
    Options::AddValueOption("-annse",  FN,  annse,  "", settings.HasAnnSeFilename,     settings.AnnSeFilename,     IO_Opts);
    Options::AddValueOption("-fq1",    FN,  fq1,    "", settings.HasFastqFilename1,    settings.FastqFilename1,    IO_Opts);
    Options::AddValueOption("-fq2",    FN,  fq2,    "", settings.HasFastqFilename2,    settings.FastqFilename2,    IO_Opts);
    Options::AddValueOption("-jmp",    FN,  jump,   "", settings.HasJumpDbStub,        settings.JumpDbStub,        IO_Opts);
    Options::AddValueOption("-mosaik", DIR, mosaik, "", settings.HasMosaikPath,        settings.MosaikPath,        IO_Opts);
    Options::AddValueOption("-out",    FN,  out,    "", settings.HasOutputFilename,    settings.OutputFilename,    IO_Opts);
    Options::AddValueOption("-ref",    FN,  ref,    "", settings.HasReferenceFilename, settings.ReferenceFilename, IO_Opts);
    Options::AddValueOption("-tmp",    DIR, tmp,    "", settings.HasScratchPath,       settings.ScratchPath,       IO_Opts, Defaults::ScratchPath);
    Options::AddOption("-keep",    keep,      settings.IsKeepGeneratedFiles, IO_Opts);
    Options::AddOption("-se",      singleEnd, settings.IsSingleEndMode,      IO_Opts );
    Options::AddOption("-v",       verbose,   settings.IsVerbose,            IO_Opts);
    Options::AddOption("-version", version,   settings.IsVersionRequested,   IO_Opts);

    OptionGroup* PremoOpts = Options::CreateOptionGroup("Premo Bootstrapping Options");

    const string dfl("delta fragment length (fraction). Premo can stop when overall median fragment length changes by less than this amount after a new batch result");
    const string drl("delta read length (fraction). Premo can stop when overall median read length changes by less than this amount after a new batch result");
    const string n("# of pairs to align per batch");

    Options::AddValueOption("-delta-fl", "double", dfl, "", settings.HasDeltaFragmentLength, settings.DeltaFragmentLength, PremoOpts, Defaults::DeltaFragmentLength);
    Options::AddValueOption("-delta-rl", "double", drl, "", settings.HasDeltaReadLength,     settings.DeltaReadLength,     PremoOpts, Defaults::DeltaReadLength);
    Options::AddValueOption("-n",        "int",    n,   "", settings.HasBatchSize,           settings.BatchSize,           PremoOpts, Defaults::BatchSize);

    OptionGroup* MosaikOpts = Options::CreateOptionGroup("Mosaik Parameter-Generation Options");

    const string act("alignment candidate threshold. Generated MosaikAligner -act parameter will be ((ActSlope * ReadLength) + ActIntercept)");
    const string bwm("banded Smith-Waterman multiplier. Generated MosaikAligner -bw parameter will be (BwMultiplier * Mmp * ReadLength)");
    const string hs("Mosaik hash size. Used in premo batch runs, and included in generated parameter set");
    const string mhp("maximum hash positions. Used in premo batch runs, and included in generated parameter set");
    const string mmp("mismatch percent. Used in premo batch runs, and included in generated parameter set");
    const string st("sequencing technology: '454', 'helicos', 'illumina', 'illumina_long', 'sanger' or 'solid'. Required for premo batch runs, and included in generated parameter set");

    Options::AddValueOption("-act-intercept", "int",    act, "", settings.HasActIntercept, settings.ActIntercept, MosaikOpts, Defaults::ActIntercept);
    Options::AddValueOption("-act-slope",     "double", act, "", settings.HasActSlope,     settings.ActSlope,     MosaikOpts, Defaults::ActSlope);
    Options::AddValueOption("-bwm",           "int",    bwm, "", settings.HasBwMultiplier, settings.BwMultiplier, MosaikOpts, Defaults::BwMultiplier);
    Options::AddValueOption("-hs",            "int",    hs,  "", settings.HasHashSize,     settings.HashSize,     MosaikOpts, Defaults::HashSize);
    Options::AddValueOption("-mhp",           "int",    mhp, "", settings.HasMhp,          settings.Mhp,          MosaikOpts, Defaults::Mhp);
    Options::AddValueOption("-mmp",           "double", mmp, "", settings.HasMmp,          settings.Mmp,          MosaikOpts, Defaults::Mmp);
    Options::AddValueOption("-st",            "string", st,  "", settings.HasSeqTech,      settings.SeqTech,      MosaikOpts  /* REQUIRED INPUT */);

    // -------------------------------------------------------
    // parse command line
    // -------------------------------------------------------

    // options class will show help, if requested
    Options::Parse(argc, argv);

    // show version info, if requested
    if ( settings.IsVersionRequested ) {
        printVersion();
        return 0;
    }

    // -------------------------------------------------------
    // run Premo using settings
    // -------------------------------------------------------

    // initialize our Premo runner with cmdline settings
    Premo p(settings);

    // run PremoApp... if failed:
    if ( !p.run() ) {

        // print error & return failure
        cerr << "premo ERROR: " << p.errorString() << endl;
        return 1;
    }

    // otherwise return success
    return 0;
}
