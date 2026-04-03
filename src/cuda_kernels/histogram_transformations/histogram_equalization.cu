#include <cuda_runtime.h>
#include <stdio.h>

#define HIST_BINS 256

__global__ void histogram_gray_kernel(unsigned char *img,
                                      unsigned int *global_hist,
                                      int N)
{
    __shared__ unsigned int local_hist[HIST_BINS];

    for (int i = threadIdx.x; i < HIST_BINS; i += blockDim.x)
        local_hist[i] = 0;

    __syncthreads();

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    while (idx < N)
    {
        unsigned char val = img[idx];
        atomicAdd(&local_hist[val], 1);
        idx += stride;
    }

    __syncthreads();

    for (int i = threadIdx.x; i < HIST_BINS; i += blockDim.x)
    {
        atomicAdd(&global_hist[i], local_hist[i]);
    }
}

__global__ void histogram_rgb_kernel(unsigned char *img,
                                        int N,
                                        unsigned int *global_hist)
{

    __shared__ unsigned int local_hist[3 * HIST_BINS];

    for (int i = threadIdx.x; i < 3 * HIST_BINS; i += blockDim.x)
        local_hist[i] = 0;

    __syncthreads();

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    while (idx < N)
    {
        int pix = 3 * idx;

        unsigned char r = img[pix + 0];
        unsigned char g = img[pix + 1];
        unsigned char b = img[pix + 2];

        atomicAdd(&local_hist[0 * HIST_BINS + r], 1);
        atomicAdd(&local_hist[1 * HIST_BINS + g], 1);
        atomicAdd(&local_hist[2 * HIST_BINS + b], 1);

        idx += stride;
    }

    __syncthreads();

    // Reduce to global histogram
    for (int i = threadIdx.x; i < 3 * HIST_BINS; i += blockDim.x)
    {
        atomicAdd(&global_hist[i], local_hist[i]);
    }
}

__global__ void apply_lut_gray(unsigned char *img,
                               unsigned char *lut,
                               int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N)
    {
        img[idx] = lut[img[idx]];
    }
}

__global__ void apply_lut_rgb(unsigned char *img,
                              unsigned char *lutR,
                              unsigned char *lutG,
                              unsigned char *lutB,
                              int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N)
    {
        int pix = 3 * idx;

        img[pix + 0] = lutR[img[pix + 0]];
        img[pix + 1] = lutG[img[pix + 1]];
        img[pix + 2] = lutB[img[pix + 2]];
    }
}
