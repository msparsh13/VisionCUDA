#pragma once
#include "Operations.hpp"

class NegativeOp : public Operation {
public:
    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
};