// ***************************************************************************
// fastqwriter.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 9 June 2012 (DB)
// ---------------------------------------------------------------------------
// FASTQ file writer
// ***************************************************************************

#ifndef FASTQWRITER_H
#define FASTQWRITER_H

#include <cstdio>
#include <string>
class Fastq;

class FastqWriter {

    // ctor & dtor
    public:
        FastqWriter(void);
        ~FastqWriter(void);

    // FastqReader interface
    public:
        void close(void);
        std::string errorString(void) const;
        std::string filename(void) const;
        bool isOpen(void) const;
        bool open(const std::string& filename);
        bool write(Fastq* entry);

    // data members
    private:
        FILE* m_stream;
        std::string m_filename;
        std::string m_errorString;
};

#endif // FASTQWRITER_H
