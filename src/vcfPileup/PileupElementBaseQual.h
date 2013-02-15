#ifndef __PILEUP_ELEMENT_BASE_QUAL_H__
#define __PILEUP_ELEMENT_BASE_QUAL_H__

#include <stdint.h>
#include "PileupElement.h"

/// This class inherits from the base class and stores base and qualities.
class PileupElementBaseQual : public PileupElement
{
public:
    PileupElementBaseQual();
    PileupElementBaseQual(bool addDelAsBase);
    PileupElementBaseQual(const PileupElementBaseQual& q);
    virtual ~PileupElementBaseQual();
 
    // Add an entry to this pileup element.  
    virtual void addEntry(SamRecord& record);

    // Perform the alalysis associated with this class.  In this case, it is
    // a print of the base & quality information associated with this position.
    virtual void analyze();

    //computes GL Scores
    void computeGLScores(int index, int16_t* GLScores, char* bases, int8_t* baseQualities);

    // Resets the entry, setting the new position associated with this element.
    virtual void reset(int refPosition, InputFile* vcfOutFile, bool addDelAsBase, double*** logGLMatrix);
    virtual void reset(int refPosition);
    		
    // Allows for repeat polymorphisms
    virtual const char* getRefAllele();
    static int MAX_READS_PER_SITE;
  
private:
    static const char UNSET_QUAL = 0xFF;
    
    static uint16_t hash16(const char* s, uint16_t seed = 0) {
        uint16_t hash = seed;
        while (*s)
        {
            hash = hash * 101  +  *s++;
        }
        return hash;
    }

    static uint32_t hash32(const char* s, uint32_t seed = 0) {
        uint32_t hash = seed;
        while (*s)
        {
            hash = hash * 101  +  *s++;
        }
        return hash;
    }

    char* myBases;
    int8_t* myMapQualities;
    int8_t* myQualities;
    char* myStrands;
    int8_t* myCycles;
    uint32_t* myReadNameHashes;
    int16_t* myGLScores;
    int myAllocatedSize;
    int myIndex;
    bool myAddDelAsBase;
    std::string myRefAllele;
    InputFile* myVcfOutFile;
    double*** myLogGLMatrix;
};

#endif
