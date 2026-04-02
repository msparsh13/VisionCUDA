#pragma once
#include "Operations.hpp"

class ClosingOp : public Operation {
private:
    int kSize;

public:
    ClosingOp(int k) : kSize(k) {}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
    };