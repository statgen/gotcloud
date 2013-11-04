// ***************************************************************************
// sebatch.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Single-end batch
// ***************************************************************************

#ifndef SEBATCH_H
#define SEBATCH_H

#include "batch.h"
class FastqReader;

class SingleEndBatch : public Batch {

    // ctor & dtor
    public:
        SingleEndBatch(FastqReader* reader, PremoSettings* settings);
        ~SingleEndBatch(void);

    // Batch interface
    public:
        Batch::RunStatus run(void);

    // data members
    private:

        // copied from main Premo app, not owned
        FastqReader* m_reader;
};

#endif // SEBATCH_H
