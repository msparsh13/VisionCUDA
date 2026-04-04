// ImageOps.cu (continue)
#include<matOp.hpp>
#include<matrix.h>
// 🔹 ADD
void AddOp::apply(unsigned char*& d_data,
                  unsigned char* d_temp,
                  int& width,
                  int& height,
                  int& channels)
{
    add(d_data, d_other, d_temp, width, height, channels);

    // 🔥 swap
    std::swap(d_data, d_temp);
}

