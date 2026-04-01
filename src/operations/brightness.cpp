#include <brightnessOp.hpp>
#include <brightness.h>

void BrightnessOp::apply(unsigned char *&d_data,
                         unsigned char *d_temp,
                         int &width,
                         int &height,
                         int &channels)
{
    int size = width * height * channels;

    brightness(d_data, size, alpha, beta);
}