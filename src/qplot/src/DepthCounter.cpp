#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cassert>
#include <cmath>
#include <vector>
#include <algorithm>

#include "DepthCounter.h"

void DepthCounter::addBase(const uint64_t& pos) {
#ifdef _DEBUG_DEPTHCOUNTER_
    fprintf(stderr, "addBase at %lu\n", pos);
#endif
    if (pos >= vector2->getStart() + vector2->getLen()) {
        static int errorCount = 0;
        fprintf(stderr, "Ignore %lu, v1[start = %lu, len = %lu], v2[start = %lu, len = %lu \n",
                pos,
                vector1->getStart(), vector1->getLen(),
                vector2->getStart(), vector2->getLen());
        if (errorCount ++ > 20) {
            fprintf(stderr, "Provided bam file have unusually long gap.\n");
            exit(1);
        }
    } else if (pos >= vector2->getStart()) {
        vector2->addBase(pos);
    } else if (pos >= vector1->getStart()) {
        vector1->addBase(pos);
    } else {
        static int nWarnings = 0;
        if (nWarnings++ <= 4) {
            fprintf(stderr, "The input sam/bam file are not sorted!\n");
        } else{
            exit(2);
        }
    }
};
/**
 * if the new read left-most position @param pos is in the second vector (this->vector2),
 * that means the first vector (this->vector1) is no longer in use.
 * so we can swap them
 */
void DepthCounter::beginNewRead(const uint64_t& pos){
#ifdef _DEBUG_DEPTHCOUNTER_
    fprintf(stderr, "beginNewRead at %lu\n", pos);
#endif
    if (pos >= this->vector2->getStart() + this->vector2->getLen()){
        calculateFrequency(this->vector1);
        calculateFrequency(this->vector2);
        this->vector1->setStart(pos);
        this->vector2->setStart(pos + this->vector1->getLen());
        this->vector1->clear();
        this->vector2->clear();
    } else if (pos >= this->vector2->getStart()){
        swapVector();
    } else {
        //assert(pos >= this->vector1->getStart());
        if (pos >= this->vector1->getStart()) {
        } else {
            fprintf(stderr, "WARNING: Rewind distVec - this means your input files may not be sorted.\n");
            calculateFrequency(this->vector1);
            calculateFrequency(this->vector2);
            this->vector1->setStart(pos);
            this->vector2->setStart(pos + this->vector1->getLen());
            this->vector1->clear();
            this->vector2->clear();
        }
    };
};
/**
 * @return frequency table
 * by default: freq from 0 - 254 is counted
 * this should be called at last
 */
void DepthCounter::swapVector() {
    // store the data in vector1
    calculateFrequency(this->vector1);
    // swap both vectors
    this->vector1->setStart(this->vector2->getStart() + this->vector2->getLen());
    this->vector1->clear();
    DepthVector* tmp = this->vector2;
    this->vector2 = this->vector1;
    this->vector1 = tmp;


};
void DepthCounter::calculateFrequency(DepthVector* v) {
    for (uint64_t i = 0; i < v->getLen(); i++) {
        uint32_t tmp = v->at(i);
        if (tmp >= MAX_DEPTH)
            freqTable[MAX_DEPTH - 1] ++;
        else
            freqTable[(int)(tmp)] ++ ;
    }
}

void printFrequency(std::vector<uint32_t>& f){
    for (unsigned int i = 0; i < MAX_DEPTH; i++){
        if (f[i] > 0) {
            fprintf(stdout, "%u: %u\n", i, f[i]);
        }
    };
};

#if 0
/**
 * To test, we need some random variables
 */

class DiscreteUniformGenerator{
public:
    DiscreteUniformGenerator(int start, int end): start(start), end(end){};
    int next() const {
        return (rand() % (end - start + 1)) + start;
    };
private:
    int start;
    int end;
};

class PoissonGenerator{
public:
    PoissonGenerator(int lambda):lambda(lambda){};
    /**
     * using Knuth algorithm in http://en.wikipedia.org/wiki/Poisson_distribution
     */
    int next() const {
        double L = exp(-lambda);
        int k = 0;
        double p = 1.0;
        do {
            k += 1;
            double u = ((double)(rand()) / RAND_MAX);
            p *= u;
        } while (p > L);
        return (k-1);
    };
private:
    int lambda;
};

int main(int argc, char *argv[])
{
    {
        fprintf(stdout, "uniform bases from 0 to 3.\n");
        DepthCounter dc(2);
        dc.beginNewRead(0);
        for (int i = 0; i <= 3; i++){
            dc.addBase(i);
        }
        printFrequency(dc.getFreqDist());
    }

    {
        fprintf(stdout, "uniform let read started from 0 to 7, each read has length 2.\n");
        DepthCounter dc(2);
        for (int i = 0; i < 7; i++){
            dc.beginNewRead(i);
            dc.addBase(i);
            dc.addBase(i+1);
        }
        printFrequency(dc.getFreqDist());
    }

    {
        fprintf(stdout, "uniform let read started from 10 to 17, each read has length 2.\n");
        DepthCounter dc(2);
        for (int i = 10; i < 17; i++){
            dc.beginNewRead(i);
            dc.addBase(i);
            dc.addBase(i+1);
        }
        printFrequency(dc.getFreqDist());
    }

    {
        fprintf(stdout, "uniform let read started from 100 to 117, each read has length 2.\n");
        DepthCounter dc(2);
        for (int i = 100; i < 117; i++){
            dc.beginNewRead(i);
            dc.addBase(i);
            dc.addBase(i+1);
        }
        printFrequency(dc.getFreqDist());
    }

    {
        fprintf(stdout, "1000 uniform read started from 0 to 10000, each read has length Poisson(35).\n");
        DiscreteUniformGenerator runif(0, 10000);
        PoissonGenerator rpoi(35);
        int startPosition[1000];
        DepthCounter dc(100);
        for (int i = 0; i < 1000; i++){
            startPosition[i] = runif.next();
        };
        std::sort(startPosition, startPosition+1000);
        for (int i = 0; i < 1000; i++){
            dc.beginNewRead(startPosition[i]);
            int l = rpoi.next();
            for (int j = 0; j < l; j++) {
                dc.addBase(startPosition[i] + j);
            }
        };
        printFrequency(dc.getFreqDist());
    }

    return 0;
}
#endif
