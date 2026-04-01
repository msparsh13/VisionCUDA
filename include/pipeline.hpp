#pragma once
#include <vector>
#include "Operations.hpp"

class Pipeline {
    std::vector<Operation*> ops;
    unsigned char* d_temp = nullptr;

public:
    void add(Operation* op);
    void init(int width, int height , int channels);
    void cleanup();
    void run(unsigned char*& d_data,
             int& width,
             int& height,
             int& channels);
};