// ***************************************************************************
// pebatch.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Paired-end batch
// ***************************************************************************

#ifndef PEBATCH_H
#define PEBATCH_H

#include "batch.h"
#include <vector>
class FastqReader;

class PairedEndBatch : public Batch {

    // ctor & dtor
    public:
        PairedEndBatch(const int batchNumber,
                       FastqReader* reader1,
                       FastqReader* reader2,
                       PremoSettings* settings);
        ~PairedEndBatch(void);

    // Batch interface
    public:
        Batch::RunStatus run(void);

    // internal methods
    private:
        RunStatus generateTempFastqFiles(void);
        RunStatus parseAlignmentFile(void);
        RunStatus runMosaikAligner(void);
        RunStatus runMosaikBuild(void);
        RunStatus runMosaikPipeline(void);

    // data members
    private:

        // copies from main Premo app, not owned
        FastqReader* m_reader1;
        FastqReader* m_reader2;

        // store all possible generated filenames, for proper cleanup
        std::string m_generatedFastq1;
        std::string m_generatedFastq2;
        std::string m_generatedReadArchive;
        std::string m_generatedBamStub;
        std::string m_generatedBam;
        std::string m_generatedMosaikLog;
        std::string m_generatedMultipleBam;
        std::string m_generatedSpecialBam;
        std::string m_generatedStatFile;
};

#endif // PEBATCH_H
