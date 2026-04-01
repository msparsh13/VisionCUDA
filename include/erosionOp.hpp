#pragma once
#include "Operations.hpp"

class ErosionOp : public Operation {
private:
    int kSize;

public:
  ErosionOp(int k) : kSize(k) {}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override ;
    };