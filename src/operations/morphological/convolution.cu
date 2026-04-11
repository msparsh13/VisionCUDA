
#include<convOp.hpp>
#include<convolution.h>
#include<kernels.hpp>
#include<padding.hpp>
#include <utility> 

__global__ void uchar_to_float(unsigned char* in, float* out, int size);


__global__ void float_to_uchar(float* in, unsigned char* out, int size);

void ConvolutionOp::apply(unsigned char*& d_data,
                          unsigned char*&d_temp,
                          int& width,
                          int& height,
                          int& channels)
{
    // if (isSeparable(kernelType))
    // {
    unsigned char* d_intermediate;
    cudaMalloc(&d_intermediate, width * height * channels);
       separable_convolution(
            d_data,
            d_temp,
            d_intermediate,   // temp reused internally
            width,
            height,
            channels,
            kernelType,
            padding,
            3
        );
    // }
    // else
    // {
    //     convolve_tiled(
    //         d_data,
    //         d_temp,
    //         width,
    //         height,
    //         channels,
    //         kernelType,
    //         padding
    //     );
    // }
  
cudaFree(d_intermediate);
    cudaDeviceSynchronize();
      std::swap(d_data, d_temp);


}