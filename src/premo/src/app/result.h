// ***************************************************************************
// result.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 24 June 2012 (DB)
// ---------------------------------------------------------------------------
// Aggregation struct for results
// ***************************************************************************

#ifndef RESULT_H
#define RESULT_H

#include <vector>

struct Result {

    // data members
    std::vector<int> FragmentLengths;
    std::vector<int> ReadLengths;

    // ctors & dtor
    Result(void) { }
    Result(const Result& other)
        : FragmentLengths(other.FragmentLengths)
        , ReadLengths(other.ReadLengths)
    { }
    ~Result(void) { }
};

#endif // RESULT_H
