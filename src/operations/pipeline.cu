#include "Pipeline.hpp"
#include <cuda_runtime.h>
#include<iostream>

void Pipeline::add(Operation *op)
{
    ops.push_back(op);
}

void Pipeline::init(int width, int height, int channels)
{
    int size = width * height * channels;
    cudaMalloc(&d_temp, size);
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
        std::cout<<channels<<std::endl;
        op->apply(d_data, d_temp, width, height, channels);
    }
}