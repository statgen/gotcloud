#ifndef _MMAPFILE_H_
#define _MMAPFILE_H_

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/mman.h>

extern size_t getFileSize(const char* fileName);

class MmapFile{
  public:
    int open(const char* fileName);
    void close();
    void* data; // mmap() data goes here
    size_t getFileSize() { return this->fileSize;};
  MmapFile():data(0){};
  private:
    size_t fileSize;
    int filedes;
};

#endif /* _MMAPFILE_H_ */
