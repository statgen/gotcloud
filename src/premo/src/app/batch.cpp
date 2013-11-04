// ***************************************************************************
// batch.cpp (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Premo batch
// ***************************************************************************

#include "batch.h"
#include "premo_settings.h"
using namespace std;

// ----------------------
// Batch implementation
// ----------------------

Batch::Batch(PremoSettings* settings)
    : m_settings(settings)
{ }

Batch::~Batch(void) { }

string Batch::errorString(void) const {
    return m_errorString;
}

Result Batch::result(void) const {
    return m_result;
}
