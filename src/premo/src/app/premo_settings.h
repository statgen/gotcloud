// ***************************************************************************
// premo_settings.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 8 August 2012 (DB)
// ---------------------------------------------------------------------------
// Premo app settings
// ***************************************************************************

#ifndef PREMO_SETTINGS_H
#define PREMO_SETTINGS_H

#include <string>

// default numerical values (can override any from command line)
namespace Defaults {

// alignment candidate threshold
// generated MosaikAligner -act = ((ActSlope * ReadLength) + ActIntercept)
const unsigned int ActIntercept = 13;
const double ActSlope = 0.2;

// banded Smith-Waterman multiplier
// generated MosaikAligner -bw = (BwMultiplier * Mmp * ReadLength)
const double BwMultiplier = 2.5;

// number of mate-pairs per premo batch
const unsigned int BatchSize = 1000;

// stop running premo batches when the total median (for both FL & RL)
// changes by less than this fraction after adding a new batch
const double DeltaFragmentLength = 0.01;
const double DeltaReadLength = 0.05;

// hash size (see Mosaik docs for details)
const unsigned int HashSize = 15;

// maximum hash positions (see Mosaik docs for details)
const unsigned int Mhp = 200;

// maximum mismatch percentage (see Mosaik docs for details)
const double Mmp = 0.15;

// directory for generated files (they're cleaned up by default)
const std::string ScratchPath(".");

} // namespace Defaults

struct PremoSettings {

    // I/O flags
    bool HasAnnPeFilename;
    bool HasAnnSeFilename;
    bool HasFastqFilename1;
    bool HasFastqFilename2;
    bool HasJumpDbStub;
    bool HasMosaikPath;
    bool HasOutputFilename;
    bool HasReferenceFilename;
    bool HasScratchPath;
    bool IsKeepGeneratedFiles;
    bool IsVerbose;
    bool IsVersionRequested;

    // premo flags
    bool HasBatchSize;
    bool HasDeltaReadLength;
    bool HasDeltaFragmentLength;
    bool IsSingleEndMode;

    // mosaik flags
    bool HasActIntercept;
    bool HasActSlope;
    bool HasBwMultiplier;
    bool HasHashSize;
    bool HasMhp;
    bool HasMmp;
    bool HasSeqTech;

    // I/O parameters
    std::string AnnPeFilename;
    std::string AnnSeFilename;
    std::string FastqFilename1;
    std::string FastqFilename2;
    std::string JumpDbStub;
    std::string MosaikPath;
    std::string OutputFilename;
    std::string ReferenceFilename;
    std::string ScratchPath;

    // premo parameters
    unsigned int BatchSize;
    double DeltaReadLength;
    double DeltaFragmentLength;

    // mosaik parameters
    unsigned int ActIntercept;
    double       ActSlope;
    double       BwMultiplier;
    unsigned int HashSize;
    unsigned int Mhp;
    double       Mmp;
    std::string  SeqTech;

    // ctors
    PremoSettings(void)
        : HasAnnPeFilename(false)
        , HasAnnSeFilename(false)
        , HasFastqFilename1(false)
        , HasFastqFilename2(false)
        , HasJumpDbStub(false)
        , HasMosaikPath(false)
        , HasOutputFilename(false)
        , HasReferenceFilename(false)
        , HasScratchPath(false)
        , IsKeepGeneratedFiles(false)
        , IsVerbose(false)
        , IsVersionRequested(false)
        , HasBatchSize(false)
        , HasDeltaReadLength(false)
        , HasDeltaFragmentLength(false)
        , IsSingleEndMode(false)
        , HasActIntercept(false)
        , HasActSlope(false)
        , HasBwMultiplier(false)
        , HasHashSize(false)
        , HasMhp(false)
        , HasMmp(false)
        , HasSeqTech(false)
        , AnnPeFilename("")
        , AnnSeFilename("")
        , FastqFilename1("")
        , FastqFilename2("")
        , JumpDbStub("")
        , MosaikPath("")
        , OutputFilename("")
        , ReferenceFilename("")
        , ScratchPath(Defaults::ScratchPath)
        , BatchSize(Defaults::BatchSize)
        , DeltaReadLength(Defaults::DeltaReadLength)
        , DeltaFragmentLength(Defaults::DeltaFragmentLength)
        , ActIntercept(Defaults::ActIntercept)
        , ActSlope(Defaults::ActSlope)
        , BwMultiplier(Defaults::BwMultiplier)
        , HashSize(Defaults::HashSize)
        , Mhp(Defaults::Mhp)
        , Mmp(Defaults::Mmp)
        , SeqTech("")
    { }

    PremoSettings(const PremoSettings& other)
        : HasAnnPeFilename(other.HasAnnPeFilename)
        , HasAnnSeFilename(other.HasAnnSeFilename)
        , HasFastqFilename1(other.HasFastqFilename1)
        , HasFastqFilename2(other.HasFastqFilename2)
        , HasJumpDbStub(other.HasJumpDbStub)
        , HasMosaikPath(other.HasMosaikPath)
        , HasOutputFilename(other.HasOutputFilename)
        , HasReferenceFilename(other.HasReferenceFilename)
        , HasScratchPath(other.HasScratchPath)
        , IsKeepGeneratedFiles(other.IsKeepGeneratedFiles)
        , IsVerbose(other.IsVerbose)
        , IsVersionRequested(other.IsVersionRequested)
        , HasBatchSize(other.HasBatchSize)
        , HasDeltaReadLength(other.HasDeltaReadLength)
        , HasDeltaFragmentLength(other.HasDeltaFragmentLength)
        , IsSingleEndMode(other.IsSingleEndMode)
        , HasActIntercept(other.HasActIntercept)
        , HasActSlope(other.HasActSlope)
        , HasBwMultiplier(other.HasBwMultiplier)
        , HasHashSize(other.HasHashSize)
        , HasMhp(other.HasMhp)
        , HasMmp(other.HasMmp)
        , HasSeqTech(other.HasSeqTech)
        , AnnPeFilename(other.AnnPeFilename)
        , AnnSeFilename(other.AnnSeFilename)
        , FastqFilename1(other.FastqFilename1)
        , FastqFilename2(other.FastqFilename2)
        , JumpDbStub(other.JumpDbStub)
        , MosaikPath(other.MosaikPath)
        , OutputFilename(other.OutputFilename)
        , ReferenceFilename(other.ReferenceFilename)
        , ScratchPath(other.ScratchPath)
        , BatchSize(other.BatchSize)
        , DeltaReadLength(other.DeltaReadLength)
        , DeltaFragmentLength(other.DeltaFragmentLength)
        , ActIntercept(other.ActIntercept)
        , ActSlope(other.ActSlope)
        , BwMultiplier(other.BwMultiplier)
        , HashSize(other.HashSize)
        , Mhp(other.Mhp)
        , Mmp(other.Mmp)
        , SeqTech(other.SeqTech)
    { }
};

#endif // PREMO_SETTINGS_H
