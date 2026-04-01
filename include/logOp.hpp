#pragma once
#include "Operations.hpp"

class LogOp : public Operation {
    int scale;
public:
    LogOp(int value) : scale(value) {};
    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
};