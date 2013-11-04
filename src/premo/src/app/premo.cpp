// ***************************************************************************
// premo.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 9 August 2012 (DB)
// ---------------------------------------------------------------------------
// Main Premo workhorse
// ***************************************************************************

#include "premo.h"

#include "batch.h"
#include "options.h"
#include "pebatch.h"
#include "sebatch.h"
#include "stats.h"

#include "jsoncpp/json_value.h"
#include "jsoncpp/json_writer.h"

#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <cassert>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>
using namespace std;

// ------------------------
// static utility methods
// ------------------------

static
Json::Value containerStats(const vector<int>& container) {

    Json::Value result(Json::objectValue);
    result["count"] = static_cast<Json::UInt>(container.size());

    if ( !container.empty() ) {

        vector<int> c = container;
        sort(c.begin(), c.end());

        const Quartiles quartiles = calculateQuartiles(c);
        result["median"] = quartiles.Q2;
        result["Q1"] = quartiles.Q1;
        result["Q3"] = quartiles.Q3;
    }

    return result;
}

static
Json::Value resultToJson(const Result& result, const bool isSingleEndMode) {

    Json::Value json(Json::objectValue);

    // include fragment length results if PE mode
    if ( !isSingleEndMode )
        json["fragment length"] = containerStats(result.FragmentLengths);

    // always include read length results
    json["read length"] = containerStats(result.ReadLengths);

    return json;
}

static
bool isConverged(const vector<int>& previous,
                 const vector<int>& current,
                 const double cutoffDelta)
{
    // sort (a copy of) input containers (req'd for median calculation)
    vector<int> currentValues  = current;
    vector<int> previousValues = previous;
    sort(currentValues.begin(),  currentValues.end());
    sort(previousValues.begin(), previousValues.end());

    // calculate medians
    const double currentMedian  = calculateMedian(currentValues);
    const double previousMedian = calculateMedian(previousValues);

    // calculate difference between previous & current values
    const double diff = fabs( currentMedian - previousMedian );

    // calculate delta (ratio) from old values
    const double observedDelta = ( diff / previousMedian );

    // return whether observed delta is below requested cutoff
    return ( observedDelta <= cutoffDelta );
}

static
bool checkFinished(const Result& previousResult,
                   const Result& currentResult,
                   const PremoSettings& settings)
{
    // SE mode
    if ( settings.IsSingleEndMode ) {

        // only check for read length convergence
        return isConverged(previousResult.ReadLengths,
                           currentResult.ReadLengths,
                           settings.DeltaReadLength);
    }

    // PE mode
    else {

        // check for both read length & fragment length convergence
        return isConverged(previousResult.FragmentLengths,
                           currentResult.FragmentLengths,
                           settings.DeltaFragmentLength)  &&
               isConverged(previousResult.ReadLengths,
                           currentResult.ReadLengths,
                           settings.DeltaReadLength);
    }
}

template<typename T>
void append(std::vector<T>& dest, const std::vector<T>& source) {
    dest.insert(dest.end(), source.begin(), source.end());
}

static inline
bool endsWith(const string& str, const string& query) {
    return ( str.find_last_of(query) == (str.length() - query.length()) );
}

static
bool dirExists(const char* directory) {

    // Borrowed from Mosaik source (w/o Windows compatibility)
    // https://github.com/wanpinglee/MOSAIK/blob/master/src/CommonSource/Utilities/FileUtilities.cpp

    bool foundDirectory = false;

    struct stat st;
    if ( stat(directory, &st) == 0 ) {
        DIR* pDirectory = opendir(directory);
        if ( pDirectory != NULL ) {
            foundDirectory = true;
            closedir( pDirectory );
        }
    }

    return foundDirectory;
}

static
bool createDirectory(const char* directory) {

    // Borrowed from Mosaik source (** w/o Windows compatibility **)
    // https://github.com/wanpinglee/MOSAIK/blob/master/src/CommonSource/Utilities/FileUtilities.cpp

    // return success if directory already exists
    if ( dirExists(directory) )
        return true;

    // otherwise return success/failure of creatin directory
    return ( mkdir(directory, S_IRWXU | S_IRGRP | S_IXGRP) == 0 );
}

static
void removeDirectory(string directory) {

    // Borrowed from Mosaik source (** w/o Windows compatibility **)
    // https://github.com/wanpinglee/MOSAIK/blob/master/src/CommonSource/Utilities/FileUtilities.cpp

    // skip out if directory doesn't exist
    if( !dirExists( directory.c_str() ) )
        return;

    // open directory
    DIR* pdir = NULL;
    pdir = opendir( directory.c_str() );
    if ( pdir == NULL )
        return;

    string file;
    struct dirent* pent = NULL;

    // iterate over directory contents
    while ( (pent = readdir(pdir)) != NULL ) {
        if ( pent == NULL ) return;

        // get full path to file & remove it
        file = directory + pent->d_name;
        remove(file.c_str());
    }

    // close the directory & remove it
    closedir(pdir);
    rmdir(directory.c_str());
}

// ----------------------
// Premo implementation
// ----------------------

Premo::Premo(const PremoSettings& settings)
    : m_settings(settings)
    , m_isFinished(false)
    , m_createdScratchDirectory(false)
{ }

Premo::~Premo(void) {

    // if user doesn't want to keep any generated files &
    // we have a scratch directory we created within this run
    if ( !m_settings.IsKeepGeneratedFiles &&
         !m_settings.ScratchPath.empty() &&
         m_createdScratchDirectory )
    {
        // remove the generated scratch directory
        removeDirectory(m_settings.ScratchPath);
    }
}

string Premo::errorString(void) const {
    return m_errorString;
}

bool Premo::openInputFiles(void) {

    // open FASTQ input files for reading
    bool openedOk = true;
    openedOk &= m_reader1.open(m_settings.FastqFilename1);
    if ( !m_settings.IsSingleEndMode )
        openedOk &= m_reader2.open(m_settings.FastqFilename2);

    // check for failures
    if ( !openedOk ) {

        // build error string
        stringstream s("");
        s << "could not open input FASTQ file(s):";

        if ( !m_reader1.isOpen() ) {
            s << endl
              << m_settings.FastqFilename1 << endl
              << "\tbecause: " << m_reader1.errorString();
        }

        if ( !m_reader2.isOpen() && !m_settings.IsSingleEndMode ) {
            s << endl
              << m_settings.FastqFilename2 << endl
              << "\tbecause: " << m_reader2.errorString();
        }

        m_errorString = s.str();

        // return failure
        return false;
    }

    // otherwise, opened OK
    if ( m_settings.IsVerbose )
        cerr << "input FASTQ file(s) opened OK" << endl;
    return true;
}

bool Premo::run(void) {

    // check that settings are valid
    if ( !validateSettings() )
        return false;

    // open our input files for reading (FastqReader dtor closes FASTQ file)
    if ( !openInputFiles() )
        return false;

    // main loop - batch processing
    int batchNumber = 0;
    while ( !m_isFinished ) {

        if ( m_settings.IsVerbose )
            cerr << "running batch: " << batchNumber << endl;

        // run batch
        Batch* batch(0);
        if ( m_settings.IsSingleEndMode )
            batch = new SingleEndBatch(&m_reader1, &m_settings);
        else
            batch = new PairedEndBatch(batchNumber, &m_reader1, &m_reader2, &m_settings);

        const Batch::RunStatus status = batch->run();

        // if we used up entire input on previous batches, that's OK...
        // but we do need to stop trying batches (and no result is available from this one)
        if ( status == Batch::NoData && batchNumber != 0 ) {

            // clean up
            delete batch;
            batch = 0;

            // break out of batch loop
            break;
        }

        // if batch failed, set error & return failure
        else if ( status == Batch::Error ) {

            // set error string
            stringstream s("");
            s << "batch " << batchNumber << " failed - " << endl
              << batch->errorString();
            m_errorString = s.str();

            // clean up
            delete batch;
            batch = 0;

            // return failure
            return false;
        }
        assert( (status == Batch::Normal) || (status == Batch::HitEOF) );

        // store batch results
        const Result result = batch->result();
        m_batchResults.push_back( result );

        // store previous result before adding batch data to "current" result
        const Result previousResult = m_currentResult;

        // add batch's data to current, overall result
        append(m_currentResult.ReadLengths, result.ReadLengths);
        if ( !m_settings.IsSingleEndMode )
            append(m_currentResult.FragmentLengths, result.FragmentLengths);

        // if we hit EOF on the input, then we're done
        // (we can't process any more batches)
        if ( status == Batch::HitEOF )
            m_isFinished = true;

        // otherwise, we finished normally - check to see if we're done
        // (unless this was the first batch)
        else if ( batchNumber > 0 )
            m_isFinished = checkFinished(previousResult, m_currentResult, m_settings);

        // increment our batch counter
        ++batchNumber;

        // clean up
        delete batch;
        batch = 0;
    }

    // output results
    if ( !writeOutput() )
        return false;

    // if we get here, return success
    return true;
}

bool Premo::validateSettings(void) {

    // -------------------------------
    // check for required parameters
    // -------------------------------

    stringstream missing("");
    bool hasMissing = false;

    // -fq1
    if ( !m_settings.HasFastqFilename1 || m_settings.FastqFilename1.empty() ) {
        missing << endl << "\t-fq1 (FASTQ filename)";
        hasMissing = true;
    }

    // -out
    if ( !m_settings.HasOutputFilename || m_settings.OutputFilename.empty() ) {
        missing << endl << "\t-out (output filename)";
        hasMissing = true;
    }

    // -st
    if ( !m_settings.HasSeqTech || m_settings.SeqTech.empty() ) {
        missing << endl << "\t-st (sequencing technology)";
        hasMissing = true;
    }

    // check required input for paired-end mode
    if ( !m_settings.IsSingleEndMode ) {

        // -annpe
        if ( !m_settings.HasAnnPeFilename || m_settings.AnnPeFilename.empty() ) {
            missing << endl << "\t-annpe (paired-end neural network filename)";
            hasMissing = true;
        }

        // -annse
        if ( !m_settings.HasAnnSeFilename || m_settings.AnnSeFilename.empty() ) {
            missing << endl << "\t-annse (single-end neural network filename)";
            hasMissing = true;
        }

        // -fq2
        if ( !m_settings.HasFastqFilename2 || m_settings.FastqFilename2.empty() ) {
            missing << endl << "\t-fq2 (FASTQ filename)";
            hasMissing = true;
        }

        // -mosaik
        if ( !m_settings.HasMosaikPath || m_settings.MosaikPath.empty() ) {
            missing << endl << "\t-mosaik (path/to/Mosaik/bin)";
            hasMissing = true;
        } else {

            // append dir separator if missing from path
            if ( !endsWith(m_settings.MosaikPath, "/") )
                m_settings.MosaikPath.append("/");
        }

        // -ref
        if ( !m_settings.HasReferenceFilename || m_settings.ReferenceFilename.empty() ) {
            missing << endl << "\t-ref (Mosaik reference archive)";
            hasMissing = true;
        }

        // -tmp
        if ( !m_settings.HasScratchPath || m_settings.ScratchPath.empty() ) {
            missing << endl << "\t-tmp (scratch directory for generated files)";
            hasMissing = true;
        } else {

            // append dir separator if missing from path
            if ( !endsWith(m_settings.ScratchPath, "/") )
                m_settings.ScratchPath.append("/");
        }
    }

    // -----------------------------------------
    // check other parameters for valid ranges
    // -----------------------------------------

    stringstream invalid("");
    bool hasInvalid = false;


    if ( m_settings.HasActSlope && m_settings.ActSlope <= 0.0 ) {
        invalid << endl << "\t-act-slope must be a positive, non-zero value";
        hasInvalid = true;
    }

    if ( m_settings.HasBatchSize && m_settings.BatchSize == 0 ) {
        invalid << endl << "\t-n cannot be zero";
        hasInvalid = true;
    }

    if ( m_settings.HasBwMultiplier && m_settings.BwMultiplier <= 0.0 ) {
        invalid << endl << "\t-bwm must be a positive, non-zero value";
        hasInvalid = true;
    }

    if ( m_settings.HasHashSize && ( m_settings.HashSize < 4 || m_settings.HashSize > 32) ) {
        invalid << endl << "-hs must be between [4-32]";
        hasInvalid = true;
    }

    if ( m_settings.HasDeltaFragmentLength && m_settings.DeltaFragmentLength <= 0.0 ) {
        invalid << endl << "\t-delta-fl must be a positive, non-zero value";
        hasInvalid = true;
    }

    if ( m_settings.HasDeltaReadLength && m_settings.DeltaReadLength <= 0.0 ) {
        invalid << endl << "\t-delta-rl must be a positive, non-zero value";
        hasInvalid = true;
    }

    if ( m_settings.HasMhp && m_settings.Mhp == 0 ) {
        invalid << endl << "\t-mhp cannot be zero";
        hasInvalid = true;
    }

    if ( m_settings.HasMmp && (m_settings.Mmp < 0.0 || m_settings.Mmp > 1.0) ) {
        invalid << endl << "\t-mmp must be in the range [0.0 - 1.0]";
        hasInvalid = true;
    }

    // check valid input for paired-end mode
    if ( !m_settings.IsSingleEndMode ) {

        // -tmp
        if ( m_settings.HasScratchPath && !m_settings.ScratchPath.empty() ) {

            // see if directory already exists
            if ( dirExists(m_settings.ScratchPath.c_str()) )
                m_createdScratchDirectory = false;

            // if not try to create it
            else {
                m_createdScratchDirectory = createDirectory(m_settings.ScratchPath.c_str());
                if ( !m_createdScratchDirectory ) {
                    invalid << endl
                            << "\tcould not create the directory specified by -tmp. "
                            << "Be sure you have mkdir permissions";
                    hasInvalid = true;
                }
            }
        }
    }

    // ---------------------------------------------------------------
    // set error string if anything missing/invalid
    // ---------------------------------------------------------------

    m_errorString.clear();

    if ( hasMissing ) {
        m_errorString.append("\nthe following parameters are missing:");
        m_errorString.append(missing.str());
    }

    if ( hasInvalid ) {
        m_errorString.append("\nthe following parameters are invalid:");
        m_errorString.append(invalid.str());
    }

    // --------------------------
    // return validation status
    // --------------------------

    const bool settingsOk = !( hasMissing || hasInvalid );

    if ( settingsOk && m_settings.IsVerbose )
        cerr << "command-line settings OK" << endl;

    return settingsOk;
}

bool Premo::writeOutput(void) {

    Json::Value root(Json::objectValue);

    // ------------------------------
    // store top-level results
    // ------------------------------

    root["overall result"] = resultToJson(m_currentResult, m_settings.IsSingleEndMode);

    // -------------------------
    // store per-batch results
    // -------------------------

    Json::Value batches(Json::arrayValue);
    vector<Result>::const_iterator batchIter = m_batchResults.begin();
    vector<Result>::const_iterator batchEnd  = m_batchResults.end();
    for ( ; batchIter != batchEnd; ++batchIter )
        batches.append( resultToJson(*batchIter, m_settings.IsSingleEndMode) );

    root["batch results"] = batches;

    // ------------------------------
    // store settings used
    // ------------------------------

    Json::Value settings(Json::objectValue);
    settings["act intercept"]         = m_settings.ActIntercept;
    settings["act slope"]             = m_settings.ActSlope;
    settings["bandwidth multiplier"]  = m_settings.BwMultiplier;
    settings["batch size"]            = m_settings.BatchSize;
    settings["delta fragment length"] = m_settings.DeltaFragmentLength;
    settings["delta read length"]     = m_settings.DeltaReadLength;
    settings["hash size"]             = m_settings.HashSize;
    settings["mhp"]                   = m_settings.Mhp;
    settings["mmp"]                   = m_settings.Mmp;
    settings["seq tech"]              = m_settings.SeqTech;

    root["settings"] = settings;

    // -------------------------------
    // generate Mosaik parameter set
    // -------------------------------

    // calculate read length median & related stats
    vector<int> readLengths  = m_currentResult.ReadLengths;
    sort(readLengths.begin(), readLengths.end());
    const double readLengthMedian = calculateMedian(readLengths);

    // calculate bandwidth parameter, rounding down to nearest odd integer
    unsigned int bandwidth = ceil( m_settings.BwMultiplier * readLengthMedian );
    if ( (bandwidth & 1) == 0  )
        bandwidth -= 1;

    // if PE mode, calculate fragment length median
    double fragLengthMedian(0.0);
    if ( !m_settings.IsSingleEndMode ) {
        vector<int> fragmentLengths = m_currentResult.FragmentLengths;
        sort(fragmentLengths.begin(), fragmentLengths.end());
        fragLengthMedian = calculateMedian(fragmentLengths);
    }

    Json::Value mosaikAlignerParameters(Json::objectValue);
    mosaikAlignerParameters["-act"] = (m_settings.ActSlope * readLengthMedian) + m_settings.ActIntercept;
    mosaikAlignerParameters["-bw"]  = bandwidth;
    mosaikAlignerParameters["-hs"]  = m_settings.HashSize;
    mosaikAlignerParameters["-mhp"] = m_settings.Mhp;
    mosaikAlignerParameters["-mmp"] = m_settings.Mmp;
    if ( !m_settings.IsSingleEndMode )
        mosaikAlignerParameters["-ls"] = fragLengthMedian;

    Json::Value mosaikBuildParameters(Json::objectValue);
    mosaikBuildParameters["-st"] = m_settings.SeqTech;
    if ( !m_settings.IsSingleEndMode )
        mosaikBuildParameters["-mfl"] = static_cast<int>(fragLengthMedian);

    Json::Value parameters(Json::objectValue);
    parameters["MosaikAligner"] = mosaikAlignerParameters;
    parameters["MosaikBuild"]   = mosaikBuildParameters;

    root["parameters"] = parameters;

    // ---------------------------
    // write JSON to output file
    // ---------------------------

    // open stream on file
    ofstream outFile(m_settings.OutputFilename.c_str());
    if ( !outFile ) {
        m_errorString = "premo ERROR: could not open final output file: ";
        m_errorString.append(m_settings.OutputFilename);
        return false;
    }

    // write "pretty-printed" JSON contents to file
    Json::StyledStreamWriter writer("  ");
    writer.write(outFile, root);

    // clean up & return success
    outFile.close();
    if ( m_settings.IsVerbose )
        cerr << "results written OK" << endl;
    return true;
}
