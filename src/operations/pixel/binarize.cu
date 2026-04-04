#include "binarizing.h"
#include "binarizeOp.hpp"
#include "grayscale.h"
#include <cuda_runtime.h>
#include <stdio.h>
void BinarizeOp::apply(unsigned char *&d_data,
                       unsigned char *d_temp,
                       int &width,
                       int &height,
                       int &channels)
{

    int size = width * height;

    unsigned char *d_out;
    cudaMalloc(&d_out, size * sizeof(unsigned char));

    if (channels == 1)
    {
        binary_gray(d_data, d_out, width, height, thresh);
    }
    else
    {
        binary(d_data, d_out, width, height, thresh);
    }
    cudaFree(d_data);
    d_data = d_out;

    channels = 1;
}