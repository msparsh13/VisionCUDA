#include <GammaOp.hpp>
#include <gamma.h>

void GammaOp::apply(unsigned char *&d_data,
                    unsigned char *d_temp,
                    int &width,
                    int &height,
                    int &channels)
{
    int size = width * height * channels;

    gamma_transform(d_data, size, gamma);
}