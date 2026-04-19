#include<matrix.h>
#include<matOp.hpp>
#include <utility> 
#include <stdexcept>
void SubtractOp::apply(unsigned char*& d_data,
                       unsigned char*&d_temp,
                       int& width,
                       int& height,
                       int& channels)
{
    subtract(d_data, other.data, d_temp, width, height, channels);
  if (width !=other.w || height != other.h || channels != other.c) {
            throw std::runtime_error("Image size mismatch");
        }
    std::swap(d_data, d_temp);
}
