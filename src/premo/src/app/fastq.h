// ***************************************************************************
// fastq.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 June 2012 (DB)
// ---------------------------------------------------------------------------
// FASTQ entry
// ***************************************************************************

#ifndef FASTQ_H
#define FASTQ_H

#include <string>

struct Fastq {

    // data members
    std::string Header;   // for this application, since we're just dumping entries back out... keep the leading '@'
    std::string Bases;
    std::string Qualities;

    // ctors & dtor
    Fastq(const std::string& h = std::string(),
          const std::string& b = std::string(),
          const std::string& q = std::string());
    Fastq(const Fastq& other);
    ~Fastq(void);

    // constants
    static const std::string AT;
    static const std::string PLUS;
};

#endif // FASTQ_H
