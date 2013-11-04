// ***************************************************************************
// premo.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 4 July 2012 (DB)
// ---------------------------------------------------------------------------
// Main Premo workhorse
// ***************************************************************************

#ifndef PREMO_H
#define PREMO_H

#include "fastqreader.h"
#include "premo_settings.h"
#include "result.h"
#include <string>
#include <vector>

class Premo {

    // ctor & dtor
    public:
        Premo(const PremoSettings& settings);
        ~Premo(void);

    // Premo interface
    public:
        std::string errorString(void) const;
        bool run(void);

    // internal methods
    private:
        bool openInputFiles(void);
        bool validateSettings(void);
        bool writeOutput(void);

    // data members
    private:
        PremoSettings m_settings;
        bool m_isFinished;

        FastqReader m_reader1;
        FastqReader m_reader2;

        std::vector<Result> m_batchResults;
        Result m_currentResult;

        bool m_createdScratchDirectory;

        std::string m_errorString;
};

#endif // PREMO_H
