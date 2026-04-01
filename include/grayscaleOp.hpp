#pragma once
#include "Operations.hpp"

enum GrayMode{
    TRIPLE,
    SINGLE,
} ;

class GrayscaleOp : public Operation {
    GrayMode mode;

public:
    GrayscaleOp(GrayMode m) : mode(m) {}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override; 
};