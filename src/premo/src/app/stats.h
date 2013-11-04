// ***************************************************************************
// stats.h (c) 2012 Derek Barnett
// Marth Lab, Department of Biology, Boston College
// ---------------------------------------------------------------------------
// Last modified: 12 Sept 2013 (DB)
// ---------------------------------------------------------------------------
// Data structures & methods for statistics
// ***************************************************************************

#ifndef STATS_H
#define STATS_H

#include <algorithm>
#include <vector>

struct Quartiles {

    // data members
    double Q1;
    double Q2;
    double Q3;

    // ctors & dtor
    Quartiles(const double q1 = 0.0,
              const double q2 = 0.0,
              const double q3 = 0.0)
        : Q1(q1)
        , Q2(q2)
        , Q3(q3)
    { }

    Quartiles(const Quartiles& other)
        : Q1(other.Q1)
        , Q2(other.Q2)
        , Q3(other.Q3)
    { }

    ~Quartiles(void) { }
};

// N.B. - expects sorted container
template<typename T>
double calculateMedian(const std::vector<T>& container) {

    if ( container.empty() )
        return 0.0;

    const size_t numElements = container.size();
    const size_t pivot       = numElements / 2;

    // even number of data points
    // return average of middle values
    if ( numElements % 2 == 0 )
        return ( container.at(pivot-1) + container.at(pivot) ) / 2.0;

    // otherwise, odd number of data points
    // return middle value
    else
        return static_cast<double>(container.at(pivot));
}

template<typename T>
Quartiles calculateQuartiles(const std::vector<T>& container) {

    Quartiles result;
    result.Q2 = calculateMedian(container);

    const size_t numElements = container.size();
    const size_t pivot       = numElements / 2;

    typedef typename std::vector<T>::const_iterator ConstIter;

    ConstIter begin = container.begin();
    ConstIter end   = container.end();

    // even number of data points
    if ( numElements % 2 == 0 ) {

        const std::vector<T> low(begin, begin + pivot);
        const std::vector<T> high(begin + pivot, end);

        result.Q1 = calculateMedian(low);
        result.Q3 = calculateMedian(high);
    }

    // otherwise, odd number of data points
    // need to count center element in both low & high
    else {

        const std::vector<T> low(begin, begin + pivot + 1);
        const std::vector<T> high(begin + pivot, end);

        result.Q1 = calculateMedian(low);
        result.Q3 = calculateMedian(high);
    }

    return result;
}

// N.B. - type T must be comparable to a double
template<typename T>
struct OutOfRange {

    OutOfRange(const double low, const double high)
        : m_low(low)
        , m_high(high)
    { }

    bool operator()(const T value) const {
        return ( value < m_low ) || ( value > m_high );
    }

    private:
        double m_low;
        double m_high;
};

template<typename T>
void removeOutliers(std::vector<T>& container) {

    // skip if container is too small to determine outliers
    if ( container.size() <= 3 )
        return;

    // sort container
    std::sort(container.begin(), container.end());

    // determine IQR & cutoffs
    const Quartiles quartiles = calculateQuartiles(container);
    const double IQR = quartiles.Q3 - quartiles.Q1;
    if ( IQR == 0.0 )
        return;

    const double cutoff = IQR * 3;
    const double lowCutoff  = quartiles.Q1 - cutoff;
    const double highCutoff = quartiles.Q3 + cutoff;

    // remove values above & below cutoffs
    container.erase( std::remove_if(container.begin(),
                                    container.end(),
                                    OutOfRange<T>(lowCutoff, highCutoff)),
                     container.end());
}

#endif // STATS_H
