#include <cuda_runtime.h>

__global__ void kernel_binary(unsigned char* img, unsigned char* out, int width, int height,
                              int thresh);

void binary(unsigned char* d_img, unsigned char* d_out, int width, int height, int thresh)
{
    dim3 block(16, 16);

    dim3 grid((width + block.x - 1) / block.x, (height + block.y - 1) / block.y);

    kernel_binary<<<grid, block>>>(d_img, d_out, width, height, thresh);

    cudaDeviceSynchronize();
}