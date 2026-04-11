#include "Pipeline.hpp"
#include <cuda_runtime.h>
#include "../include/stb_image_write.h"
#include<iostream>
#define CUDA_CHECK(x)                                                     \
do {                                                                      \
    cudaError_t err = (x);                                                \
    if (err != cudaSuccess) {                                             \
        std::cerr << "CUDA Error: "                                       \
                  << cudaGetErrorString(err)                              \
                  << " at " << __FILE__ << ":" << __LINE__ << std::endl;  \
        exit(1);                                                          \
    }                                                                     \
} while (0)
void Pipeline::add(Operation *op)
{
    ops.push_back(op);
}

void Pipeline::init(int width, int height, int channels)
{
    int size = width * height * channels;
    cudaMalloc(&d_temp, size* sizeof(unsigned char));
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
        op->apply(d_data, d_temp, width, height, channels);

    }
}