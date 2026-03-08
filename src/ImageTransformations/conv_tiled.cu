#include "../../include/padding.hpp"
#include "../../include/kernels.hpp"


__global__ void conv_tiled(
    float* input,
    float* output,
    float* kernel,
    int width,
    int height,
    int kSize) ;

void convolve_tiled(
    float* h_input,
    float* h_output,
    int width,
    int height,
    KernelType kernelType,
    PaddingType padding)
{
    int kSize;


    //TODO: implement padding 
    auto kernelVec = getKernel(kernelType, kSize);

    float* d_input;
    float* d_output;
    float* d_kernel;

    size_t imgSize = width * height * sizeof(float);
    size_t kerSize = kSize * kSize * sizeof(float);

    cudaMalloc(&d_input, imgSize);
    cudaMalloc(&d_output, imgSize);
    cudaMalloc(&d_kernel, kerSize);

    cudaMemcpy(d_input, h_input, imgSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_kernel, kernelVec.data(), kerSize, cudaMemcpyHostToDevice);

    dim3 block(16,16);
    dim3 grid((width+15)/16,(height+15)/16);

    int radius = kSize/2;
    int sharedMem = (16 + 2*radius)*(16 + 2*radius)*sizeof(float);

    conv_tiled<<<grid,block,sharedMem>>>(
        d_input,
        d_output,
        d_kernel,
        width,
        height,
        kSize
    );

    cudaMemcpy(h_output, d_output, imgSize, cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);
    cudaFree(d_kernel);
}
