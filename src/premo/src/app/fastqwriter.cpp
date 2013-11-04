// ***************************************************************************
// fastqwriter.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 9 June 2012 (DB)
// ---------------------------------------------------------------------------
// FASTQ file writer
// ***************************************************************************

#include "fastqwriter.h"
#include "fastq.h"
#include <cassert>
using namespace std;

// ----------------------------
// FastqWriter implementation
// ----------------------------

FastqWriter::FastqWriter(void)
    : m_stream(0)
{ }

FastqWriter::~FastqWriter(void) {
    close();
}

void FastqWriter::close(void) {

    // close file stream
    if ( m_stream ) {
        fclose(m_stream);
        m_stream = 0;
    }

    // erase stored filename
    m_filename.clear();
}

string FastqWriter::errorString(void) const {
    return m_errorString;
}

string FastqWriter::filename(void) const {
    return m_filename;
}

bool FastqWriter::isOpen(void) const {
    return ( m_stream != 0 );
}

bool FastqWriter::open(const string& filename) {

    // ensure clean slate
    close();

    // attempt to open
    m_stream = fopen(filename.c_str(), "w");
    if ( m_stream == 0 ) {

        // if failed, set error & return failure
        m_errorString = "could not open output FASTQ file: ";
        m_errorString.append(filename);
        return false;
    }

    // store filename & return success
    m_filename = filename;
    return true;
}

bool FastqWriter::write(Fastq* entry) {

    // fail if unopened file
    if ( m_stream == 0 ) {
        m_errorString = "cannot write to unopened writer";
        return false;
    }

    // sanity checks
    assert(entry);

    // write entry's data
    fputs(entry->Header.c_str(), m_stream);    fputc('\n', m_stream); // assumes Header contains leading '@'
    fputs(entry->Bases.c_str(), m_stream);     fputc('\n', m_stream);
    fputc('+', m_stream);                      fputc('\n', m_stream);
    fputs(entry->Qualities.c_str(), m_stream); fputc('\n', m_stream);

    // return success
    return true;
}
