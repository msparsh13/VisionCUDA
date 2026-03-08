#include <cuda_runtime.h>

__global__ void conv_tiled(
    float* input,
    float* output,
    float* kernel,
    int width,
    int height,
    int kSize)
{
    int radius = kSize / 2;

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = blockIdx.y * blockDim.y + ty;
    int col = blockIdx.x * blockDim.x + tx;

    int shared_w = blockDim.x + 2 * radius;

    extern __shared__ float tile[];

    int shared_x = tx + radius;
    int shared_y = ty + radius;

    // Load center pixel
    if(row < height && col < width)
        tile[shared_y * shared_w + shared_x] =
            input[row * width + col];
    else
        tile[shared_y * shared_w + shared_x] = 0;

    // Load halo pixels
    for(int dy = -radius; dy <= radius; dy++)
    {
        for(int dx = -radius; dx <= radius; dx++)
        {
            int global_x = col + dx;
            int global_y = row + dy;

            int shared_hx = shared_x + dx;
            int shared_hy = shared_y + dy;

            if(shared_hx >= 0 && shared_hx < shared_w &&
               shared_hy >= 0 && shared_hy < blockDim.y + 2*radius)
            {
                if(global_x >= 0 && global_x < width &&
                   global_y >= 0 && global_y < height)
                {
                    tile[shared_hy * shared_w + shared_hx] =
                        input[global_y * width + global_x];
                }
                else
                {
                    tile[shared_hy * shared_w + shared_hx] = 0;
                }
            }
        }
    }

    __syncthreads();

    if(row < height && col < width)
    {
        float sum = 0.0f;

        for(int ky = 0; ky < kSize; ky++)
        {
            for(int kx = 0; kx < kSize; kx++)
            {
                float pixel =
                    tile[(ty + ky) * shared_w + (tx + kx)];

                float k =
                    kernel[ky * kSize + kx];

                sum += pixel * k;
            }
        }

        output[row * width + col] = sum;
    }
}