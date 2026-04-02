// #include <cuda_runtime.h>

// #include <iostream>

#include "convolution.h"
#include "kernels.hpp"
#include "padding.hpp"
#define RADIUS 1
#define BLOCK_SIZE 16
#define TILE 16
#define CUDA_CHECK(x)                                                                           \
    do                                                                                          \
    {                                                                                           \
        cudaError_t err = x;                                                                    \
        if (err != cudaSuccess)                                                                 \
        {                                                                                       \
            std::cerr << "CUDA Error: " << cudaGetErrorString(err) << " at " << __FILE__ << ":" \
                      << __LINE__ << std::endl;                                                 \
            exit(1);                                                                            \
        }                                                                                       \
    } while (0)

__global__ void conv_tiled(
    float* input,
    float* output,
    float* kernel,
    int width,
    int height,
    int channels,
    int kSize);

void convolve_tiled(float* d_input,
                    float* d_output,
                    int width,
                    int height,
                    int channels,
                    KernelType kernelType,
                    PaddingType padding)
{
    int kSize;
    auto kernelVec = getKernel2D(kernelType, kSize);

    float* d_kernel;
    cudaMalloc(&d_kernel, kSize * kSize * sizeof(float));

    cudaMemcpy(d_kernel,
               kernelVec.data(),
               kSize * kSize * sizeof(float),
               cudaMemcpyHostToDevice);

    dim3 block(TILE, TILE);
    dim3 grid((width + TILE - 1) / TILE,
              (height + TILE - 1) / TILE);

    int radius = kSize / 2;
    int ch = min(channels, 4);

    int sharedMem =
        (TILE + 2 * radius) *
        (TILE + 2 * radius) *
        ch *
        sizeof(float);

    conv_tiled<<<grid, block, sharedMem>>>(
        d_input, d_output, d_kernel,
        width, height, channels, kSize);

    cudaDeviceSynchronize();
    cudaGetLastError();

    cudaFree(d_kernel);
}


__global__ void conv_vertical(
    unsigned char *input,
    unsigned char *output,
    float *kernel,
    int width,
    int height,
    int channels);

__global__ void conv_horizontal(
    unsigned char *input,
    unsigned char *output,
    float *kernel,
    int width,
    int height,
    int channels);

void separable_convolution(unsigned char* d_input,
                           unsigned char* d_output,
                           unsigned char* d_temp,
                           int width,
                           int height,
                           int channels,
                           KernelType kernelType,
                           PaddingType padding,
                           int kSize)
{
    auto kernelVecX = getKernel1D_X(kernelType, kSize);
    auto kernelVecY = getKernel1D_Y(kernelType, kSize);

    float *d_kernelX, *d_kernelY;

    cudaMalloc(&d_kernelX, kSize * sizeof(float));
    cudaMalloc(&d_kernelY, kSize * sizeof(float));

    cudaMemcpy(d_kernelX, kernelVecX.data(),
               kSize * sizeof(float), cudaMemcpyHostToDevice);

    cudaMemcpy(d_kernelY, kernelVecY.data(),
               kSize * sizeof(float), cudaMemcpyHostToDevice);

    dim3 block(BLOCK_SIZE, BLOCK_SIZE);
    dim3 grid((width + BLOCK_SIZE - 1) / BLOCK_SIZE,
              (height + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // 🔹 Horizontal pass
    conv_horizontal<<<grid, block>>>(
        d_input,
        d_temp,
        d_kernelX,
        width,
        height,
        channels
    );
    cudaDeviceSynchronize();

    // 🔹 Vertical pass
    conv_vertical<<<grid, block>>>(
        d_temp,
        d_output,
        d_kernelY,
        width,
        height,
        channels
    );
    cudaDeviceSynchronize();

    cudaFree(d_kernelX);
    cudaFree(d_kernelY);
}


// void convolve(float* d_input,
//               float* d_output,
//               float* d_temp,
//               int width,
//               int height,
//               KernelType kernelType,
//               PaddingType padding)
// {
//     if (isSeparable(kernelType))
//     {
//         separable_convolution(d_input, d_output, d_temp,
//                               width, height, kernelType, padding, 3);
//     }
//     else
//     {
//         convolve_tiled(d_input, d_output,
//                        width, height, kernelType, padding);
//     }
// }