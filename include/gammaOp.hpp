#pragma once
#include "Operations.hpp"

class GammaOp : public Operation {
    float gamma;
public:
    GammaOp(int value) : gamma(value) {};
    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
};