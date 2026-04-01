#include <negativeOp.hpp>
#include <negative.h>

void NegativeOp::apply(unsigned char *&d_data,
                       unsigned char *d_temp,
                       int &width,
                       int &height,
                       int &channels)
{
    int size = width * height * channels;

    negative(d_data, size);
}