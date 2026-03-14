#include <cuda_runtime.h>
#include <stdio.h>

#define HIST_BINS 256
#define WARP_SIZE 32

__device__ int atomicAggInc(unsigned int* ctr)
{
    unsigned int active = __activemask();
    int leader = __ffs(active) - 1;
    int change = __popc(active);
    unsigned int lane = threadIdx.x & 31;
    unsigned int rank = __popc(active & ((1u << lane) - 1));

    int warp_res;
    if (rank == 0) warp_res = atomicAdd(ctr, change);
    warp_res = __shfl_sync(active, warp_res, leader);

    return warp_res + rank;
}

__global__ void histogram_kernel(unsigned char* img, unsigned int* global_hist, int N)
{
    __shared__ unsigned int shared_hist[HIST_BINS + 32];
    for (int i = threadIdx.x; i < HIST_BINS; i += blockDim.x) shared_hist[i] = 0;

    __syncthreads();

    // Grid-stride loop over image pixels
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    while (idx < N)
    {
        unsigned char value = img[idx];

        unsigned int* hist_bin = &shared_hist[value];
        atomicAggInc(hist_bin);

        idx += stride;
    }

    __syncthreads();

    for (int i = threadIdx.x; i < HIST_BINS; i += blockDim.x)
    {
        atomicAdd(&global_hist[i], shared_hist[i]);
    }
}

__global__ void apply_lut(unsigned char* img, unsigned char* lut, int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < N) img[idx] = lut[img[idx]];
}

__global__ void histogram_rgb_kernel(unsigned char* img, int width, int height, unsigned int* histR,
                                     unsigned int* histG, unsigned int* histB)
{
    __shared__ unsigned int sharedR[HIST_BINS];
    __shared__ unsigned int sharedG[HIST_BINS];
    __shared__ unsigned int sharedB[HIST_BINS];

    int tid = threadIdx.x + threadIdx.y * blockDim.x;

    for (int i = tid; i < HIST_BINS; i += blockDim.x * blockDim.y)
    {
        sharedR[i] = 0;
        sharedG[i] = 0;
        sharedB[i] = 0;
    }
    __syncthreads();

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int idy = blockIdx.y * blockDim.y + threadIdx.y;
    int strideX = blockDim.x * gridDim.x;
    int strideY = blockDim.y * gridDim.y;

    for (int y = idy; y < height; y += strideY)
    {
        for (int x = idx; x < width; x += strideX)
        {
            int pix_idx = (y * width + x) * 3;
            unsigned char r = img[pix_idx + 0];
            unsigned char g = img[pix_idx + 1];
            unsigned char b = img[pix_idx + 2];
            atomicAggInc(&sharedR[r]);
            atomicAggInc(&sharedG[g]);
            atomicAggInc(&sharedB[b]);
        }
    }

    __syncthreads();

    for (int i = tid; i < HIST_BINS; i += blockDim.x * blockDim.y)
    {
        atomicAdd(&histR[i], sharedR[i]);
        atomicAdd(&histG[i], sharedG[i]);
        atomicAdd(&histB[i], sharedB[i]);
    }

    __syncthreads();

    if (tid == 0)
    {
        int cdfR[HIST_BINS], cdfG[HIST_BINS], cdfB[HIST_BINS];
        cdfR[0] = histR[0];
        cdfG[0] = histG[0];
        cdfB[0] = histB[0];
        int N = width * height;
        int cdfR_min = 0, cdfG_min = 0, cdfB_min = 0;

        for (int i = 1; i < HIST_BINS; i++)
        {
            cdfR[i] = cdfR[i - 1] + histR[i];
            cdfG[i] = cdfG[i - 1] + histG[i];
            cdfB[i] = cdfB[i - 1] + histB[i];

            if (cdfR_min == 0 && cdfR[i] != 0) cdfR_min = cdfR[i];
            if (cdfG_min == 0 && cdfG[i] != 0) cdfG_min = cdfG[i];
            if (cdfB_min == 0 && cdfB[i] != 0) cdfB_min = cdfB[i];
        }

        for (int i = 0; i < HIST_BINS; i++)
        {
            histR[i] = (cdfR[i] < cdfR_min) ? 0 : (cdfR[i] - cdfR_min) * 255 / (N - cdfR_min);
            histG[i] = (cdfG[i] < cdfG_min) ? 0 : (cdfG[i] - cdfG_min) * 255 / (N - cdfG_min);
            histB[i] = (cdfB[i] < cdfB_min) ? 0 : (cdfB[i] - cdfB_min) * 255 / (N - cdfB_min);
        }
    }
    __syncthreads();

    for (int y = idy; y < height; y += strideY)
    {
        for (int x = idx; x < width; x += strideX)
        {
            int pix_idx = (y * width + x) * 3;
            img[pix_idx + 0] = histR[img[pix_idx + 0]];
            img[pix_idx + 1] = histG[img[pix_idx + 1]];
            img[pix_idx + 2] = histB[img[pix_idx + 2]];
        }
    }
}

__global__ void apply_lut_rgb(unsigned char* img, unsigned char* lutR, unsigned char* lutG,
                              unsigned char* lutB, int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N)
    {
        img[3 * idx + 0] = lutR[img[3 * idx + 0]];
        img[3 * idx + 1] = lutG[img[3 * idx + 1]];
        img[3 * idx + 2] = lutB[img[3 * idx + 2]];
    }
}