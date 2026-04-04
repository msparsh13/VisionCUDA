#include<matrix.h>
#include<matOp.hpp>

void ScaleOp::apply(unsigned char*& d_data,
                    unsigned char* d_temp,
                    int& width,
                    int& height,
                    int& channels)
{
    scale(d_data, width, height, channels, factor);
}