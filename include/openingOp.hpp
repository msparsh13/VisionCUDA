#pragma once
#include "Operations.hpp"

class OpeningOp : public Operation {
private:
    int kSize;

public:
    OpeningOp(int k) : kSize(k) {}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
    };