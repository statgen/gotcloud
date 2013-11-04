// ***************************************************************************
// pebatch.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Paired-end batch
// ***************************************************************************

#include "pebatch.h"

#include "fastq.h"
#include "fastqreader.h"
#include "fastqwriter.h"
#include "premo_settings.h"
#include "stats.h"

#include "bamtools/api/BamReader.h"

#include <cassert>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <algorithm>
#include <iostream>
#include <numeric>
#include <sstream>
#include <vector>
using namespace std;

// -------------------------
// utility methods
// -------------------------

static inline
int32_t calculateFragmentLength(const BamTools::BamAlignment& mate1,
                                const BamTools::BamAlignment& mate2)
{
    assert( abs(mate1.InsertSize) == abs(mate2.InsertSize) );
    return mate1.Length + abs(mate1.InsertSize) + mate2.Length;
}

// ----------------------
// PairedEndBatch implementation
// ----------------------

PairedEndBatch::PairedEndBatch(const int batchNumber,
                               FastqReader* reader1,
                               FastqReader* reader2,
                               PremoSettings* settings)
    : Batch(settings)
    , m_reader1(reader1)
    , m_reader2(reader2)
{
    // ----------------------------
    // set up generated filenames
    // ----------------------------

    const string prefix("premo_batch");

    stringstream s;

    // mate1 FASTQ
    s.str("");
    s << m_settings->ScratchPath << prefix << batchNumber << "_mate1.fq";
    m_generatedFastq1 = s.str();

    // mate2 FASTQ
    s.str("");
    s << m_settings->ScratchPath << prefix << batchNumber << "_mate2.fq";
    m_generatedFastq2 = s.str();

    // Mosaik read archive
    s.str("");
    s << m_settings->ScratchPath << prefix << batchNumber << "_reads.mkb";
    m_generatedReadArchive = s.str();

    // Mosaik alignment files
    s.str("");
    s << m_settings->ScratchPath << prefix << batchNumber << "_aligned";
    m_generatedBamStub = s.str();

    m_generatedBam = m_generatedBamStub;
    m_generatedBam.append(".bam");

    m_generatedMosaikLog = m_generatedBamStub;
    m_generatedMosaikLog.append(".mosaiklog");

    m_generatedMultipleBam = m_generatedBamStub;
    m_generatedMultipleBam.append(".multiple.bam");

    m_generatedSpecialBam = m_generatedBamStub;
    m_generatedSpecialBam.append(".special.bam");

    m_generatedStatFile = m_generatedBamStub;
    m_generatedStatFile.append(".stat");
}

PairedEndBatch::~PairedEndBatch(void) {

    // auto-delete any generated files (unless requested otherwise)
    if ( !m_settings->IsKeepGeneratedFiles ) {
        remove(m_generatedFastq1.c_str());
        remove(m_generatedFastq2.c_str());
        remove(m_generatedReadArchive.c_str());
        remove(m_generatedBam.c_str());
        remove(m_generatedMosaikLog.c_str());
        remove(m_generatedMultipleBam.c_str());
        remove(m_generatedSpecialBam.c_str());
        remove(m_generatedStatFile.c_str());
    }
}

Batch::RunStatus PairedEndBatch::generateTempFastqFiles(void) {

    // ------------------------------
    // open temp FASTQ output files
    // ------------------------------

    FastqWriter writer1;
    FastqWriter writer2;

    bool openedOk = true;
    openedOk &= writer1.open(m_generatedFastq1);
    openedOk &= writer2.open(m_generatedFastq2);

    // check for failures
    if ( !openedOk ) {

        // build error string
        stringstream s("");
        s << "could not create the following temp FASTQ file(s):";
        if ( !writer1.isOpen() ) {
            s << endl
              << m_generatedFastq1 << endl
              << "\tbecause: " << writer1.errorString();
        }
        if ( !writer2.isOpen() ) {
            s << endl
              << m_generatedFastq2 << endl
              << "\tbecause: " << writer2.errorString();
        }
        m_errorString = s.str();

        // return failure
        return Batch::Error;
    }

    // -----------------------------------------------------------
    // copy next batch of FASTQ entries from input to temp files
    // -----------------------------------------------------------

    Fastq f1;
    Fastq f2;

    // iterate over requested number of entries
    for ( size_t i = 0; i < m_settings->BatchSize; ++i ) {

        // attempt to read from FASTQ
        const bool read1Ok = m_reader1->readNext(&f1);
        const bool read2Ok = m_reader2->readNext(&f2);

        // if both read OK
        if ( read1Ok && read2Ok ) {

            // attempt to write to FASTQ
            const bool write1Ok = writer1.write(&f1);
            const bool write2Ok = writer2.write(&f2);

            // handle any write errors
            if ( !write1Ok || !write2Ok ) {

                // build error string
                stringstream s("");
                s << "could not write to temp FASTQ file(s):";
                if ( !write1Ok ) {
                    s << endl
                      << writer1.filename() << endl
                      << "\tbecause: " << writer1.errorString();
                }
                if ( !write2Ok ) {
                    s << endl
                      << writer2.filename() << endl
                      << "\tbecause: " << writer2.errorString();
                }
                m_errorString = s.str();

                // return failure
                return Batch::Error;
            }
        }

        // handle read errors
        else {

            // handle EOF or empty file
            if ( m_reader1->isEOF() ) {

                if ( i != 0 ) {
                    assert(m_reader2->isEOF());
                    return Batch::HitEOF;
                } else
                    return Batch::NoData;
            }

            // for any other errors,
            // build error string
            stringstream s("");
            s << "could not read from input FASTQ file(s): ";
            if ( !read1Ok ) {
                s << endl
                  << m_reader1->filename() << endl
                  << "\tbecause: " << m_reader1->errorString();
            }
            if ( !read2Ok ) {
                s << endl
                  << m_reader2->filename() << endl
                  << "\tbecause: " << m_reader2->errorString();
            }
            m_errorString = s.str();
            return Batch::Error;
        }
    }

    // if we get here, all should be OK
    // cleanup & return success
    writer1.close();
    writer2.close();
    return Batch::Normal;
}

Batch::RunStatus PairedEndBatch::parseAlignmentFile(void) {

    // open reader on new BAM alignment file
    BamTools::BamReader reader;
    if ( !reader.Open(m_generatedBam) ) {
        m_errorString = "could not open generated BAM file: ";
        m_errorString.append(m_generatedBam);
        m_errorString.append(" to parse alignments");
        return Batch::Error;
    }

    // set up data containers
    m_result.ReadLengths.reserve(2 * m_settings->BatchSize);
    m_result.FragmentLengths.reserve(m_settings->BatchSize);

    // plow through alignments
    BamTools::BamAlignment mate1;
    BamTools::BamAlignment mate2;
    while ( reader.GetNextAlignmentCore(mate1) ) {

        // store mate1 read length, regardless of aligned state
        m_result.ReadLengths.push_back(mate1.Length);

        // read mate2
        if ( reader.GetNextAlignmentCore(mate2) ) {

            // store mate2 read length, regardless of aligned state
            m_result.ReadLengths.push_back(mate2.Length);

            // if both mates mapped to same reference
            if ( mate1.IsMapped() &&
                 mate2.IsMapped() &&
                 (mate1.RefID == mate2.RefID) )
            {
                // calculate & store fragment length
                m_result.FragmentLengths.push_back( calculateFragmentLength(mate1, mate2) );
            }
        }
    }
    reader.Close();

    // remove extreme outliers
    removeOutliers(m_result.FragmentLengths);
    removeOutliers(m_result.ReadLengths);

    // if we get here, all should be OK
    return Batch::Normal;
}

Batch::RunStatus PairedEndBatch::run(void) {

    Batch::RunStatus status;

    // generate temp files
    status = generateTempFastqFiles();
    if ( (status != Batch::Normal) && (status != Batch::HitEOF) ) // EOF on FASTQ is ok, we still have data to align
        return status;

    // run mosaik
    status = runMosaikPipeline();
    if ( status != Batch::Normal )
        return status;

    // parse BAM for counts & return final status
    status = parseAlignmentFile();
    return status;
}

Batch::RunStatus PairedEndBatch::runMosaikAligner(void) {

    // setup MosaikAlign command line
    stringstream commandStream("");
    commandStream << m_settings->MosaikPath << "MosaikAligner"
                  << " -ia "    << m_settings->ReferenceFilename
                  << " -in "    << m_generatedReadArchive
                  << " -out "   << m_generatedBamStub
                  << " -annpe " << m_settings->AnnPeFilename
                  << " -annse " << m_settings->AnnSeFilename
                  << " -hs "    << m_settings->HashSize
                  << " -mhp "   << m_settings->Mhp
                  << " -mmp "   << m_settings->Mmp
                  << " -kd -pd ";

    if ( m_settings->HasJumpDbStub && !m_settings->JumpDbStub.empty() )
        commandStream << " -j " << m_settings->JumpDbStub;
    if ( !m_settings->IsVerbose )
        commandStream << " -quiet >> " << m_generatedMosaikLog;

    // run MosaikAlign
    const string command = commandStream.str();
    const int result = system(command.c_str());
    return ( result == 0 ? Batch::Normal : Batch::Error );
}

Batch::RunStatus PairedEndBatch::runMosaikBuild(void) {

    // setup MosaikBuild command line
    stringstream commandStream("");
    commandStream << m_settings->MosaikPath << "MosaikBuild"
                  << " -q "   << m_generatedFastq1
                  << " -q2 "  << m_generatedFastq2
                  << " -out " << m_generatedReadArchive
                  << " -st "  << m_settings->SeqTech;
    if ( !m_settings->IsVerbose )
        commandStream << " -quiet >> " << m_generatedMosaikLog;

    // run MosaikBuild
    const string command = commandStream.str();
    const int result = system(command.c_str());
    return ( result == 0 ? Batch::Normal : Batch::Error );
}

Batch::RunStatus PairedEndBatch::runMosaikPipeline(void) {

    Batch::RunStatus status;

    // build mosaik archives for new batch FASTQ files
    status = runMosaikBuild();
    if ( status != Batch::Normal )
        return status;

    // align batch & return status
    status = runMosaikAligner();
    return status;
}
