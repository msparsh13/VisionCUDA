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
    int size = width * height * channels;

    unsigned char* h_debug = new unsigned char[size];

    int i = 0;

    for (auto op : ops)
    {
        op->apply(d_data, d_temp, width, height, channels);

        // 🔹 Copy d_data
        cudaMemcpy(h_debug, d_data, size, cudaMemcpyDeviceToHost);
        stbi_write_png("output_data.png",
                       width, height, channels,
                       h_debug, width * channels);

        // 🔹 Copy d_temp
        cudaMemcpy(h_debug, d_temp, size, cudaMemcpyDeviceToHost);
        stbi_write_png("output_temp.png",
                       width, height, channels,
                       h_debug, width * channels);

        i++;
    }

    delete[] h_debug;
}