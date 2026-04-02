#pragma once

#include "Operations.hpp"
#include "kernels.hpp"
#include "padding.hpp"

class ConvolutionOp : public Operation
{
private:
    KernelType kernelType;
    PaddingType padding;

public:

    ConvolutionOp(KernelType kType, PaddingType pad = PaddingType::ZERO)
        : kernelType(kType), padding(pad) {}


    void apply(unsigned char*& d_input,
               unsigned char* d_output,
               int& width,
               int& height,
               int& channels) override;
    };