#pragma once
#include "Operations.hpp"

class BrightnessOp : public Operation {
    float alpha;
    float beta;

public:
    BrightnessOp(float a, float b) : alpha(a), beta(b) {}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override;
};