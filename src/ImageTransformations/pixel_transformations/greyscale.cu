#include <cuda_runtime.h>

__global__ void kernel_grayscale_triple(unsigned char *img, int width, int height);

__global__ void kernel_grayscale_single(unsigned char *img, unsigned char *out, int width,
                                        int height);

//[r ,g , b]-> [gray , gray , gray]

void grayscale_triple(unsigned char *d_img, int width, int height)
{
    dim3 block(16, 16);

    dim3 grid((width + block.x - 1) / block.x, (height + block.y - 1) / block.y);

    kernel_grayscale_triple<<<grid, block>>>(d_img, width, height);
}

// [r, g , b] -> [gray]
void grayscale_single(unsigned char *d_img, unsigned char *d_out, int width, int height)
{
    dim3 block(16, 16);

    dim3 grid((width + block.x - 1) / block.x, (height + block.y - 1) / block.y);

    kernel_grayscale_single<<<grid, block>>>(d_img, d_out, width, height);
}
