#pragma once
#include "Operations.hpp"

class DilationOp : public Operation {
private:
    int kSize;

public:
    DilationOp(int k) : kSize(k) {}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
    };