#include <vector>
#include<iostream>
#include <cuda_runtime.h>
#include "kernels.hpp"
#include "padding.hpp"
#define CUDA_CHECK(msg) \
{ \
    cudaError_t err = cudaDeviceSynchronize(); \
    if (err != cudaSuccess) { \
        printf("CUDA ERROR at %s: %s\n", msg, cudaGetErrorString(err)); \
        exit(-1); \
    } \
}

// --- Forward declarations ---
__global__ void conv_vertical(unsigned char *, unsigned char *, float *, int, int, int);
__global__ void conv_horizontal(unsigned char *, unsigned char *, float *, int, int, int);
__global__ void upsample(unsigned char *, unsigned char *, int, int, int, int);
__global__ void subtract_img(unsigned char *, unsigned char *, unsigned char *, int, int, int);
__global__ void scale_img(unsigned char *, int, int, int, int);

void pyramid_gaussian(
    unsigned char *h_input,
    std::vector<unsigned char *> &outputs,
    int width,
    int height,
    int kSize,
    int scale,
    int channels,
    int levels);

// --- Laplacian Pyramid ---
void pyramid_laplacian(
    unsigned char *h_input,
    std::vector<unsigned char *> &laplacian,
    int width,
    int height,
    int kSize,
    int scale,
    int channels,
    int levels)
{
    std::vector<unsigned char *> gaussian;

    // Build Gaussian pyramid


    pyramid_gaussian(h_input, gaussian, width, height, kSize, scale, channels, levels);



    dim3 block(16, 16);

    float *d_kernel_X;
    float *d_kernel_Y;

    auto kernelVec_X = getKernel1D_X(KernelType::GAUSSIAN, kSize);
    auto kernelVec_Y = getKernel1D_Y(KernelType::GAUSSIAN, kSize);

    cudaMalloc(&d_kernel_X, kSize * sizeof(float));
    cudaMemcpy(d_kernel_X, kernelVec_X.data(), kSize * sizeof(float), cudaMemcpyHostToDevice);

    cudaMalloc(&d_kernel_Y, kSize * sizeof(float));
    cudaMemcpy(d_kernel_Y, kernelVec_Y.data(), kSize * sizeof(float), cudaMemcpyHostToDevice);



    for (int l = 0; l < (int)gaussian.size() - 1; l++)
    {
        int curr_w = width;
        int curr_h = height;
        for (int i = 0; i < l; i++)
        {
            curr_w /= scale;
            curr_h /= scale;
        }

        int next_w = curr_w / scale;
        int next_h = curr_h / scale;
        size_t curr_size = curr_w * curr_h * channels * sizeof(unsigned char);
        size_t next_size = next_w * next_h * channels * sizeof(unsigned char);

        unsigned char *d_curr, *d_next, *d_up, *d_temp, *d_blur, *d_lap;


        cudaMalloc(&d_curr, curr_size);
        cudaMalloc(&d_next, next_size);
        cudaMalloc(&d_up, curr_size);
        cudaMalloc(&d_temp, curr_size);
        cudaMalloc(&d_blur, curr_size);
        cudaMalloc(&d_lap, curr_size);

        cudaError_t err;

        cudaMemcpy(d_curr, gaussian[l], curr_size, cudaMemcpyHostToDevice);
        cudaMemcpy(d_next, gaussian[l + 1], next_size, cudaMemcpyHostToDevice);


        dim3 grid((curr_w + 15) / 16, (curr_h + 15) / 16);


        upsample<<<grid, block>>>(d_next, d_up, next_w, next_h, scale, channels);

        conv_horizontal<<<grid, block>>>(d_up, d_temp, d_kernel_X, curr_w, curr_h, channels);
        conv_vertical<<<grid, block>>>(d_temp, d_blur, d_kernel_Y, curr_w, curr_h, channels);



        scale_img<<<grid, block>>>(d_blur, curr_w, curr_h, channels, scale * scale);
        subtract_img<<<grid, block>>>(d_curr, d_blur, d_lap, curr_w, curr_h, channels);


        cudaDeviceSynchronize();
          err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("CUDA ERROR: %s\n", cudaGetErrorString(err));
        }

        unsigned char *h_out = new unsigned char[curr_w * curr_h * channels];
        cudaMemcpy(h_out, d_lap, curr_size, cudaMemcpyDeviceToHost);

        laplacian.push_back(h_out);

        cudaFree(d_curr);
        cudaFree(d_next);
        cudaFree(d_up);
        cudaFree(d_temp);
        cudaFree(d_blur);
        cudaFree(d_lap);
    }
    cudaFree(d_kernel_X);
    cudaFree(d_kernel_Y);
    laplacian.push_back(gaussian.back());
}