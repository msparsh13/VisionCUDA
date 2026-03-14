#include <cuda_runtime.h>

#include <iostream>

#include "convolution.h"
#include "kernels.hpp"
#include "padding.hpp"
#define RADIUS 1
#define BLOCK_SIZE 16
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

__global__ void conv_tiled(float* input, float* output, float* kernel, int width, int height,
                           int kSize);

void convolve_tiled(float* h_input, float* h_output, int width, int height, KernelType kernelType,
                    PaddingType padding)
{
    int kSize;

    // TODO: implement padding
    auto kernelVec = getKernel2D(kernelType, kSize);

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

    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);

    int radius = kSize / 2;
    int sharedMem = (16 + 2 * radius) * (16 + 2 * radius) * sizeof(float);

    conv_tiled<<<grid, block, sharedMem>>>(d_input, d_output, d_kernel, width, height, kSize);

    cudaMemcpy(h_output, d_output, imgSize, cudaMemcpyDeviceToHost);

    cudaFree(d_input);
    cudaFree(d_output);
    cudaFree(d_kernel);
}

__global__ void conv_vertical(float* input, float* output, float* kernel, int width, int height);

__global__ void conv_horizontal(float* input, float* output, float* kernel, int width, int height);

void separable_convolution(float* h_input, float* h_output, int width, int height,
                           KernelType kernelType, PaddingType padding, int kSize)
{
    float *d_input, *d_output, *d_temp;

    int size = width * height * sizeof(float);

    CUDA_CHECK(cudaMalloc(&d_input, size));
    CUDA_CHECK(cudaMalloc(&d_output, size));
    CUDA_CHECK(cudaMalloc(&d_temp, size));

    CUDA_CHECK(cudaMemcpy(d_input, h_input, size, cudaMemcpyHostToDevice));

    auto kernelVecX = getKernel1D_X(kernelType, kSize);
    auto kernelVecY = getKernel1D_Y(kernelType, kSize);

    float* d_kernelX;
    float* d_kernelY;

    CUDA_CHECK(cudaMalloc(&d_kernelX, kSize * sizeof(float)));
    CUDA_CHECK(cudaMalloc(&d_kernelY, kSize * sizeof(float)));

    CUDA_CHECK(
        cudaMemcpy(d_kernelX, kernelVecX.data(), kSize * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(
        cudaMemcpy(d_kernelY, kernelVecY.data(), kSize * sizeof(float), cudaMemcpyHostToDevice));

    dim3 block(BLOCK_SIZE, BLOCK_SIZE);
    dim3 grid((width + BLOCK_SIZE - 1) / BLOCK_SIZE, (height + BLOCK_SIZE - 1) / BLOCK_SIZE);

    conv_horizontal<<<grid, block>>>(d_input, d_temp, d_kernelX, width, height);

    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaGetLastError());

    conv_vertical<<<grid, block>>>(d_temp, d_output, d_kernelY, width, height);

    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaGetLastError());

    CUDA_CHECK(cudaMemcpy(h_output, d_output, size, cudaMemcpyDeviceToHost));

    cudaFree(d_input);
    cudaFree(d_output);
    cudaFree(d_temp);
    cudaFree(d_kernelX);
    cudaFree(d_kernelY);
}
void convolve(float* h_input, float* h_output, int width, int height, KernelType kernelType,
              PaddingType padding)
{
    if (isSeparable(kernelType))
    {
        separable_convolution(h_input, h_output, width, height, kernelType, padding, 3);
    }
    else
    {
        convolve_tiled(h_input, h_output, width, height, kernelType, padding);
    }
}

void convolve_img(unsigned char* h_input, unsigned char* h_output, int width, int height,
                  KernelType kernelType, PaddingType padding)
{
    if (!h_input)
    {
        std::cerr << "Error: h_input is null!\n";
        return;
    }

    int pixels = width * height;

    float* h_input_f = new float[pixels];
    float* h_output_f = new float[pixels];

    for (int i = 0; i < pixels; i++) h_input_f[i] = static_cast<float>(h_input[i]);

    convolve(h_input_f, h_output_f, width, height, kernelType, padding);

    for (int i = 0; i < pixels; i++)
    {
        float v = h_output_f[i];

        if (v < 0) v = 0;
        if (v > 255) v = 255;

        h_output[i] = static_cast<unsigned char>(v);
    }

    delete[] h_input_f;
    delete[] h_output_f;
}