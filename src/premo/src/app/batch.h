// ***************************************************************************
// batch.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Premo batch interface
// ***************************************************************************

#ifndef BATCH_H
#define BATCH_H

#include "result.h"
#include <string>
class PremoSettings;

class Batch {

    // enums
    public:
        enum RunStatus { Normal = 0  // batch processed normally, result available
                       , HitEOF      // batch hit EOF before processing settings.BatchSize reads,
                                     // result available but any further batch runs will return NoData
                       , NoData      // empty file (or starting from EOF) - NO result available
                       , Error       // any other error case - NO result available
                       };

    // ctor & dtor
    protected:
        Batch(PremoSettings* settings);
    public:
        virtual ~Batch(void);

    // Batch interface
    public:
        virtual std::string errorString(void) const;
        virtual Result result(void) const;
        virtual Batch::RunStatus run(void) =0;        // implementation depends on SE/PE mode

    // data members (accessible to subclasses)
    protected:

        // copied from main Premo app, not owned
        PremoSettings* m_settings;

        // our main result
        Result m_result;

        // error reporting
        std::string m_errorString;
};

#endif // BATCH_H
