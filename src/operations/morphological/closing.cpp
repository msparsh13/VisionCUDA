#include <closingOp.hpp>
#include <dilation.h>
#include <stdio.h>

void ClosingOp::apply(unsigned char *&d_data,
                      unsigned char *d_temp,
                      int &width,
                      int &height,
                      int &channels)
{
    if (channels != 1)
    {
        printf("OpeningOp requires grayscale input\n");
        return;
    }

    dilation(d_temp, d_data, width, height, kSize);
    erosion(d_data, d_temp, width, height, kSize);

 
}