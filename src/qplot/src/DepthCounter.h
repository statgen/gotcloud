#ifndef _DEPTHCOUNTER_H_
#define _DEPTHCOUNTER_H_

#define MAX_DEPTH 255
/**
 * DepthVector store the depth over certain length on the genome
 * Member variable vector[i] will store the depth on position (start+i)
 */
class DepthVector{
public:
    DepthVector(uint64_t len){
        this->vector = (uint32_t*) malloc (sizeof(uint32_t) * len);
        this->len = len;
        if (!vector) {
            fprintf(stderr, "Memory allocation failed");
            exit(2);
        }
        this->clear();
    };
    /**
     * fill vector with zeroes
     */
    void clear(){
        if (vector) {
            memset(vector, 0, sizeof(uint32_t) * len);
        }
    };
    uint64_t getStart() const{
        return this->start;
    };
    uint64_t getLen() const{
        return this->len;
    };
    void setStart(const uint64_t start) {
        this->start = start;
    };
    void addBase(const uint64_t& pos) {
        assert( start <= pos && pos < start + len);
        if (this->vector[pos - start] <MAX_DEPTH)
            this->vector[pos - start] ++;
    };
    uint32_t& at(const uint64_t& i) {
        return this->vector[i];
    };
private:
    uint64_t start; // 0-based index
    uint64_t len;
    uint32_t* vector;
}; // end DepthVector

class DepthCounter{
public:
    DepthCounter(){
        // Increase DepthVector length so that avoid aborting.
        // Init(65536);
        Init(1048576);
    }
    DepthCounter(uint64_t len) {
        Init(len);
    }
    void Init(uint64_t len) {
        vector1 = NULL;
        vector2 = NULL;
        vector1 = new DepthVector(len);
        vector2 = new DepthVector(len);
        assert (vector1 && vector2);
        // set initial values
        vector1->setStart(0);
        vector2->setStart(len);
        freqTable.resize(MAX_DEPTH);
    };
    ~DepthCounter(){
        if (vector1) delete vector1;
        if (vector2) delete vector2;
    }
    void addBase(const uint64_t& pos);
    /**
     * if the new read left-most position @param pos is in the second vector (this->vector2),
     * that means the first vector (this->vector1) is no longer in use.
     * so we can swap them
     */
    void beginNewRead(const uint64_t& pos);
    void clear() {
        this->vector1->setStart(0);
        this->vector1->clear();
        this->vector2->setStart(this->vector1->getLen());
        this->vector1->clear();
        std::fill(this->freqTable.begin(), this->freqTable.end(), 0);
    };
    /**
     * @return frequency table
     * by default: freq from 0 - 254 is counted
     * this should be called at last
     */
    const std::vector<uint32_t> & getFreqDist(){
        calculateFrequency(this->vector1);
        calculateFrequency(this->vector2);
        return this->freqTable;
    };
private:
    void swapVector();
    void calculateFrequency(DepthVector* v);
private:
    DepthVector* vector1; // store leading bases 
    DepthVector* vector2; // store trailing bases
    std::vector<uint32_t> freqTable;
};


#endif /* _DEPTHCOUNTER_H_ */
