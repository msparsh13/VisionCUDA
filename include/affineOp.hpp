#pragma once
#include "Operations.hpp"
#include<affine.h>
#include<vector>

class AffineOp : public Operation {
private:
    std::vector<TransformOp> ops;

public:
    void addTranslate(float tx, float ty);
    void addRotate(float theta);
    void addShear(float shx, float shy);

    void apply(unsigned char*& d_data,
                unsigned char* d_out,
               int& width,
               int& height,
               int& channels) override;
};