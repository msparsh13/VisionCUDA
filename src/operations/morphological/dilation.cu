#include <stdio.h>
#include <dilationOp.hpp>
#include <dilation.h>

void DilationOp::apply(unsigned char *&d_data,
                       unsigned char *d_temp,
                       int &width,
                       int &height,
                       int &channels)
{
    if (channels != 1)
    {
        printf("DilationOp requires binarized input\n");
        return;
    }

    dilation(d_data, d_temp, width, height, kSize);
    std::swap(d_data, d_temp);
}