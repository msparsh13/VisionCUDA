#include <cuda_runtime.h>

__global__
void kernel_negative(unsigned char* img, int size)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < size)
        img[idx] = 255 - img[idx];
}

