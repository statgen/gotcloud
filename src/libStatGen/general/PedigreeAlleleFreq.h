#ifndef __ALLELEFREQUENCIES_H__
#define __ALLELEFREQUENCIES_H__

#include "Pedigree.h"

int  CountAlleles(Pedigree & ped, int marker);
void LumpAlleles(Pedigree & ped, int marker, double threshold, bool reorder);

#define FREQ_ALL        0
#define FREQ_FOUNDERS   1
#define FREQ_EQUAL      2

// Returns true if frequencies estimated, false if previous information okay
bool EstimateFrequencies(Pedigree & ped, int marker, int estimator);

#endif


