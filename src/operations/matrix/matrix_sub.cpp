#include<matrix.h>
#include<matOp.hpp>

void SubtractOp::apply(unsigned char*& d_data,
                       unsigned char* d_temp,
                       int& width,
                       int& height,
                       int& channels)
{
    subtract(d_data, d_other, d_temp, width, height, channels);

    std::swap(d_data, d_temp);
}
