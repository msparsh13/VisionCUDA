#include <grayscaleOp.hpp>
#include <grayscale.h>

void GrayscaleOp::apply(unsigned char *&d_data,
                        unsigned char *d_temp,
                        int &width,
                        int &height,
                        int &channels)
{
    if (channels != 3)
        return;

    if (mode == GrayMode::TRIPLE)
    {

        grayscale_triple(d_data, width, height);
    }
    else
    {

        grayscale_single(d_data, d_temp, width, height);

        std::swap(d_data, d_temp);

        channels = 1;
    }
}