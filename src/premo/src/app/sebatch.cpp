// ***************************************************************************
// sebatch.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Single-end batch
// ***************************************************************************

#include "sebatch.h"
#include "fastq.h"
#include "fastqreader.h"
#include "premo_settings.h"

#include <sstream>
using namespace std;

// -------------------------------
// SingleEndBatch implementation
// -------------------------------

SingleEndBatch::SingleEndBatch(FastqReader* reader, PremoSettings* settings)
    : Batch(settings)
    , m_reader(reader)
{ }

SingleEndBatch::~SingleEndBatch(void) { }

Batch::RunStatus SingleEndBatch::run(void) {

    // calculate read lengths
    m_result.ReadLengths.reserve(m_settings->BatchSize);

    // iterate over requested number of entries
    Fastq fasta;
    for ( size_t i = 0; i < m_settings->BatchSize; ++i ) {

        // attempt to read from FASTQ
        if ( m_reader->readNext(&fasta) ) {

            // store read length
            m_result.ReadLengths.push_back( static_cast<int>(fasta.Bases.length()) );
        }

        // if failed to read
        else {

            // handle EOF or empty file
            if ( m_reader->isEOF() )
                return ( (i != 0) ? Batch::HitEOF : Batch::NoData );

            // for any other error types, build error string & return error
            stringstream s("");
            s << "could not read from input FASTQ file: " << endl
              << m_reader->filename() << endl
              << "\tbecause: " << m_reader->errorString();
            m_errorString = s.str();
            return Batch::Error;
        }
    }

    // if we get here, batch processed OK
    return Batch::Normal;
}
