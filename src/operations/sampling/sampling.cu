#include<SamplingOp.hpp>
#include<sampling.h>

#include<stdio.h>

void SamplingOp::apply(unsigned char*& d_data,
                       unsigned char* d_temp,  
                       int& width,
                       int& height,
                       int& channels)
{
    unsigned char* d_out = nullptr;

    if (type == SamplingType::UPSAMPLE)
    {
        int new_width  = width * scale;
        int new_height = height * scale;

        size_t new_size = new_width * new_height * channels;
        cudaMalloc(&d_out, new_size);

        upsample(d_data, d_out, width, height, scale, channels);

        width  = new_width;
        height = new_height;
    }
    else if (type == SamplingType::DOWNSAMPLE)
    {
        int new_width  = width / scale;
        int new_height = height / scale;

        size_t new_size = new_width * new_height * channels;
        cudaMalloc(&d_out, new_size);

        downsample(d_data, d_out, width, height, scale, channels);

        width  = new_width;
        height = new_height;
    }
    else
    {
        printf("SamplingOp: Unknown type\n");
        return;
    }
    cudaFree(d_data);
    d_data = d_out;
}