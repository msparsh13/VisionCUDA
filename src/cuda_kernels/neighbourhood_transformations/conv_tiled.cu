#include <cuda_runtime.h>

#define TILE 16
#define TILE 16

__global__ void conv_tiled(
    float* input,
    float* output,
    float* kernel,
    int width,
    int height,
    int channels,
    int kSize)
{
    int radius = kSize / 2;

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = blockIdx.y * TILE + ty;
    int col = blockIdx.x * TILE + tx;

    int shared_w = TILE + 2 * radius;
    int shared_h = TILE + 2 * radius;

    int ch = min(channels, 4);

    extern __shared__ float tile[]; 

    for (int y = ty; y < shared_h; y += blockDim.y)
    {
        for (int x = tx; x < shared_w; x += blockDim.x)
        {
            int global_x = blockIdx.x * TILE + x - radius;
            int global_y = blockIdx.y * TILE + y - radius;

            global_x = max(0, min(global_x, width - 1));
            global_y = max(0, min(global_y, height - 1));

            int global_base = (global_y * width + global_x) * channels;
            int shared_base = (y * shared_w + x) * ch;

            for (int c = 0; c < ch; c++)
            {
                tile[shared_base + c] = input[global_base + c];
            }
        }
    }

    __syncthreads();

    if (row < height && col < width)
    {
        int out_base = (row * width + col) * channels;
        int active_ch = min(channels, 3);

        for (int c = 0; c < active_ch; c++)
        {
            float sum = 0.0f;

            for (int ky = 0; ky < kSize; ky++)
            {
                for (int kx = 0; kx < kSize; kx++)
                {
                    int shared_idx = ((ty + ky) * shared_w + (tx + kx)) * ch + c;
                    float pixel = tile[shared_idx];
                    float k = kernel[ky * kSize + kx];

                    sum += pixel * k;
                }
            }

            output[out_base + c] = sum;
        }

        // 🔹 Preserve alpha
        if (channels == 4)
        {
            output[out_base + 3] = input[out_base + 3];
        }
    }
}