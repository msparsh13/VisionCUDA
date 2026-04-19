#include<SamplingOp.hpp>
#include<sampling.h>

#include<stdio.h>




void SamplingOp::apply(unsigned char*& d_data,
                       unsigned char*& d_temp,
                       int& width,
                       int& height,
                       int& channels)
{
    int new_width, new_height;
    if (type == SamplingType::UPSAMPLE)
    {
        new_width  = width * scale;
        new_height = height * scale;

        upsamplefunc(d_data, d_temp, width, height, scale, channels);
    }
    else if (type == SamplingType::DOWNSAMPLE)
    {
        new_width  = width / scale;
        new_height = height / scale;

        downsamplefunc(d_data, d_temp, width, height, scale, channels);
    }
    else
    {
        printf("SamplingOp: Unknown type\n");
        return;
    }
    std::swap(d_data, d_temp);
    width  = new_width;
    height = new_height;
}