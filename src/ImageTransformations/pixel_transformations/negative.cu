#include <cuda_runtime.h>
#include "../include/negative.h"

__global__ void kernel_negative(unsigned char *img, int size);

void negative(unsigned char *d_img, int size)
{
    int blockSize = 256;
    int numBlocks = (size + blockSize - 1) / blockSize;

    kernel_negative<<<numBlocks, blockSize>>>(d_img, size);
}