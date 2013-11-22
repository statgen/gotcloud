// ***************************************************************************
// fastqreader.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 9 May 2013 (DB)
// ---------------------------------------------------------------------------
// FASTQ file reader
// ***************************************************************************

#include "fastqreader.h"
#include "fastq.h"
#include <zlib.h>
#include <bamtools/api/bamtools_global.h>
#include <cassert>
#include <cstdio>
#include <cstring>
#include <sstream>
using namespace std;

// -------------------------
// helper stream classes
// -------------------------

class IStream {
    protected:
        IStream(void) { }
    public:
        virtual ~IStream(void) { }

    public:
        virtual void  close(void) =0;
        virtual char  getc(void) =0;
        virtual char* gets(char* dest, const size_t length) =0;
        virtual bool  isEOF(void) const =0;
        virtual bool  isOpen(void) const =0;
        virtual void  open(const char* filename) =0;
        virtual int   ungetc(const char c) =0;
};

class FileStream : public IStream {

    public:
        FileStream(void): IStream(), file(0) { }
        ~FileStream(void) { }
    public:
        void close(void)                            { fclose(file); }
        char getc(void)                             { return fgetc(file); }
        char* gets(char* dest, const size_t length) { return fgets(dest, length, file); }
        bool isEOF(void) const                      { return ( feof(file) != 0 ); }
        bool isOpen(void) const                     { return file != 0; }
        void open(const char* filename)             { file = fopen(filename, "rb"); }
        int ungetc(const char c)                    { return ::ungetc(c, file); }
    private:
        FILE* file;
};

class GzFileStream : public IStream {

    public:
        GzFileStream(void) : IStream(), file(0) { }
        ~GzFileStream(void) { }
    public:
        void close(void)                            { gzclose(file); }
        char getc(void)                             { return gzgetc(file); }
        char* gets(char* dest, const size_t length) { return gzgets(file, dest, length); }
        bool isEOF(void) const                      { return ( gzeof(file) != 0 ); }
        bool isOpen(void) const                     { return file != 0; }
        void open(const char* filename)             { file = gzopen(filename, "rb"); }
        int ungetc(const char c)                    { return gzungetc(c, file); }
    private:
        gzFile file;
};

// ------------------------
// static utility methods
// ------------------------

static
void chomp(char* s) {

    size_t length = strlen(s);
    if ( length == 0 )
        return;
    --length;

    while ( (s[length] == 10) || (s[length] == 13) ) {
        s[length] = 0;
        --length;
        if ( length < 0 )
            break;
    }
}

// ----------------------------
// FastqReader implementation
// ----------------------------

FastqReader::FastqReader(void)
    : m_stream(0)
    , m_isCompressed(false)
    , m_buffer(0)
    , m_bufferLength(0)
{ }

FastqReader::~FastqReader(void) {
    close();
}

void FastqReader::close(void) {

    // close file stream
    if ( isOpen() ) {
        m_stream->close();
        delete m_stream;
        m_stream = 0;
    }

    // clean up allocated memory
    if ( m_buffer ) {
        delete[] m_buffer;
        m_buffer = 0;
        m_bufferLength = 0;
    }

    // clear any other file-dependent data
    m_filename.clear();
    m_isCompressed = false;
}

string FastqReader::errorString(void) const {
    return m_errorString;
}

string FastqReader::filename(void) const {
    return m_filename;
}

bool FastqReader::isEOF(void) const {
    if ( isOpen() )
        return m_stream->isEOF();
    else
        return false;
}

bool FastqReader::isOpen(void) const {
    return m_stream != 0 && m_stream->isOpen();
}

bool FastqReader::open(const string& filename) {

    // ensure clean slate
    close();
    assert(m_stream == 0);

    // -----------------------------
    // check the compression state
    // -----------------------------

    FILE* checkStream = fopen(filename.c_str(), "rb");
    if ( checkStream == 0 ) {

        // if failed, set error & return failure
        m_errorString = "could not open input FASTQ file: ";
        m_errorString.append(filename);
        return false;
    }

    const uint16_t GZIP_MAGIC_NUMBER = 0x8b1f;
    uint16_t magicNumber = 0;
    const size_t numElements = fread((char*)&magicNumber, sizeof(magicNumber), 1, checkStream);
    if ( numElements != 1 ) {
        m_errorString = "could not read from input FASTQ file: ";
        m_errorString.append(filename);
        return false;
    }
    fclose(checkStream);

    m_isCompressed = ( magicNumber == GZIP_MAGIC_NUMBER );
    if ( m_isCompressed )
        m_stream = new GzFileStream;
    else
        m_stream = new FileStream;

    // ----------------------
    // attempt to open file
    // ----------------------

    m_stream->open(filename.c_str());
    if ( !isOpen() ) {

        // if failed, set error & return failure
        m_errorString = "could not open input FASTQ file: ";
        m_errorString.append(filename);
        return false;
    }

    // create an input buffer
    m_bufferLength = 4096;
    m_buffer = new char[m_bufferLength]();

    // store filename & return success
    m_filename = filename;
    return true;
}

bool FastqReader::readNext(Fastq *entry) {

    // fail if unopened file
    if ( !isOpen() ) {
        m_errorString = "cannot read from unopened reader";
        return false;
    }

    // sanity checks
    assert(entry);
    assert(m_buffer);

    // read header
    char* result;
    result = m_stream->gets(m_buffer, m_bufferLength);
    if ( m_stream->isEOF() ) {
        m_errorString = "could not read full FASTQ entry from file: ";
        m_errorString.append(m_filename);
        return false;
    }

    if ( m_buffer[0] != '@' ) {
        m_errorString = "malformed FASTQ entry - expected '@' in header, instead found: ";
        m_errorString.append(1, m_buffer[0]);
        return false;
    }
    chomp(m_buffer);
    entry->Header.assign(m_buffer);

    // read bases
    ostringstream sb("");
    while ( true ) {
        const char c = m_stream->getc();
        m_stream->ungetc(c);
        if ( c == '+' || m_stream->isEOF() )
            break;
        result = m_stream->gets(m_buffer, m_bufferLength);
        chomp(m_buffer);
        sb << m_buffer;
    }
    entry->Bases.assign(m_buffer);
    const size_t numBases = entry->Bases.length();

    // read qualities
    result = m_stream->gets(m_buffer, m_bufferLength);
    sb.str("");
    size_t numQualities = 0;
    while ( true ) {
        const char c = m_stream->getc();
        m_stream->ungetc(c);
        if ( m_stream->isEOF() )
            break;
        result = m_stream->gets(m_buffer, m_bufferLength);
        chomp(m_buffer);
        numQualities += strlen(m_buffer);
        sb << m_buffer;
        if ( numQualities >= numBases )
            break;
    }
    entry->Qualities.assign(m_buffer);

    // sanity check
    if ( entry->Qualities.length() != entry->Bases.length() ) {
        m_errorString = "malformed FASTQ entry - the number of qualities does not match the number of bases";
        return false;
    }

    // return success
    return true;
}
