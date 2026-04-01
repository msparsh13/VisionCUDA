#pragma once
#include "Operations.hpp"

class BinarizeOp : public Operation {
    int thresh;
public:
    BinarizeOp(int threshold) : thresh(threshold) {};

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override;
};