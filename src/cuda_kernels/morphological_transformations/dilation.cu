#include <cuda_runtime.h>

#define TILE 16
__global__ void dilation_tiled(unsigned char *input,
                               unsigned char *output,
                               int width, int height,
                               int kSize)
{
    int radius = kSize / 2;

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = blockIdx.y * TILE + ty;
    int col = blockIdx.x * TILE + tx;

    int shared_w = TILE + 2 * radius;
    int shared_h = TILE + 2 * radius;

    extern __shared__ unsigned char tile[];

    for (int y = ty; y < shared_h; y += blockDim.y)
    {
        for (int x = tx; x < shared_w; x += blockDim.x)
        {
            int global_x = blockIdx.x * TILE + x - radius;
            int global_y = blockIdx.y * TILE + y - radius;

            global_x = max(0, min(global_x, width - 1));
            global_y = max(0, min(global_y, height - 1));

            tile[y * shared_w + x] = input[global_y * width + global_x];
        }
    }

    __syncthreads();

    if (row < height && col < width)
    {
        unsigned char max_val = 0;

        for (int ky = 0; ky < kSize; ky++)
        {
            for (int kx = 0; kx < kSize; kx++)
            {
                unsigned char pixel = tile[(ty + ky) * shared_w + (tx + kx)];
                max_val = max(max_val, pixel);
            }
        }

        output[row * width + col] = max_val;
    }
}