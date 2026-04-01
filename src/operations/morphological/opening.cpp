#include <openingOp.hpp>
#include <dilation.h>
#include <stdio.h>

void OpeningOp::apply(unsigned char *&d_data,
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

    erosion(d_data, d_temp, width, height, kSize);

    dilation(d_temp, d_data, width, height, kSize);
}