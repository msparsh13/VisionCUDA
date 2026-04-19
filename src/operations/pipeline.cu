#include "Pipeline.hpp"
#include <cuda_runtime.h>
#include "../include/stb_image_write.h"
#include<iostream>
void Pipeline::add(Operation *op)
{
    ops.push_back(op);
}

void Pipeline::init(int width, int height, int channels)
{
    capacity = width * height * channels;
    cudaMalloc(&d_temp, capacity * sizeof(unsigned char));
}

void Pipeline::cleanup()
{
    cudaFree(d_temp);
}
void Pipeline::run(unsigned char *&d_data,
                   int &width,
                   int &height,
                   int &channels)
{
for (auto op : ops)
{
    ensureCapacity(width, height, channels);
    op->apply(d_data, d_temp, width, height, channels);
}
}

void Pipeline::ensureCapacity(int width, int height, int channels)
{
    size_t required = width * height * channels;

    if (required > capacity)
    {
        cudaFree(d_temp);
        cudaMalloc(&d_temp, required * sizeof(unsigned char));
        capacity = required;
    }
}