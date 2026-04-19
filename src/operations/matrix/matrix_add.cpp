
#include<matOp.hpp>
#include<matrix.h>
#include <utility> 
#include <stdexcept>

#include <stdexcept>

void AddOp::apply(unsigned char*& d_data,
                  unsigned char*& d_temp,
                  int& width,
                  int& height,
                  int& channels)
{
    if (width != other.w || height != other.h || channels != other.c) {
        throw std::runtime_error("AddOp: Image size mismatch");
    }
    add(d_data, other.data, d_temp, width, height, channels);
    std::swap(d_data, d_temp);
}
