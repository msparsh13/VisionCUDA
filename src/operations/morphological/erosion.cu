#include <stdio.h>
#include <ErosionOp.hpp>
#include <dilation.h>
#include <utility> 

void ErosionOp::apply(unsigned char *&d_data,
                      unsigned char *d_temp,
                      int &width,
                      int &height,
                      int &channels)
{
    if (channels != 1)
    {
        printf("Erosion requires binarized input\n");
        return;
    }

    erosion(d_data, d_temp, width, height, kSize);
    std::swap(d_data, d_temp);
}