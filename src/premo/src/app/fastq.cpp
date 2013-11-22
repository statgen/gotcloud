// ***************************************************************************
// fastq.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 June 2012 (DB)
// ---------------------------------------------------------------------------
// FASTQ entry
// ***************************************************************************

#include "fastq.h"
using namespace std;

const string Fastq::AT   = "@";
const string Fastq::PLUS = "+";

Fastq::Fastq(const string& h, const string& b, const string& q)
    : Header(h)
    , Bases(b)
    , Qualities(q)
{ }

Fastq::Fastq(const Fastq &other)
    : Header(other.Header)
    , Bases(other.Bases)
    , Qualities(other.Qualities)
{ }

Fastq::~Fastq(void) { }
