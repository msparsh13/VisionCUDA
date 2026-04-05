#include <cuda_runtime.h>
#include <stdio.h>

#define TILE 16


__global__ void subtract_img(
    unsigned char* A,
    unsigned char* B,
    unsigned char* out,
    int width,
    int height,
    int channels);

__global__ void multiply_cuda(
    float *A,
    float *B,
    float *C,
    int N, int K, int M);

__global__ void add_img(unsigned char *A, unsigned char *B, unsigned char *out, int width, int height, int channels);

__global__ void scale_img(
    unsigned char* img,
    int width,
    int height,
    int channels,
    int factor);


void add(unsigned char* A,
               unsigned char* B,
               unsigned char* out,
               int width,
               int height,
               int channels)
{
    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);

    add_img<<<grid, block>>>(A, B, out, width, height, channels);
    cudaDeviceSynchronize();
}

void subtract(unsigned char* A,
                    unsigned char* B,
                    unsigned char* out,
                    int width,
                    int height,
                    int channels)
{
    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);

    subtract_img<<<grid, block>>>(A, B, out, width, height, channels);
    cudaDeviceSynchronize();
}


void scale(unsigned char* img,
                 int width,
                 int height,
                 int channels,
                 int factor)
{
    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);

    scale_img<<<grid, block>>>(img, width, height, channels, factor);
    cudaDeviceSynchronize();
}

void mul(float* d_A,
                  float* d_B,
                  float* d_C,
                  int M, int K, int N)
{
    dim3 block(TILE, TILE);
    dim3 grid((N + TILE - 1) / TILE,
              (M + TILE - 1) / TILE);

    size_t shared_mem = 2 * TILE * TILE * sizeof(float);

    multiply_cuda<<<grid, block, shared_mem>>>(d_A, d_B, d_C, M, K, N);
    cudaDeviceSynchronize();
}