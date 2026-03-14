#define RADIUS 1
#define BLOCK_SIZE 16

__global__ void conv_horizontal(float* input, float* output, float* kernel, int width, int height)
{
    __shared__ float tile[BLOCK_SIZE][BLOCK_SIZE + 2 * RADIUS];

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int x = blockIdx.x * BLOCK_SIZE + tx;
    int y = blockIdx.y * BLOCK_SIZE + ty;

    int shared_x = tx + RADIUS;

    if (x < width && y < height)
        tile[ty][shared_x] = input[y * width + x];
    else
        tile[ty][shared_x] = 0;

    if (tx < RADIUS)
    {
        int left = x - RADIUS;
        int right = x + BLOCK_SIZE;

        tile[ty][tx] = (left >= 0) ? input[y * width + left] : 0;
        tile[ty][tx + BLOCK_SIZE + RADIUS] = (right < width) ? input[y * width + right] : 0;
    }

    __syncthreads();

    if (x < width && y < height)
    {
        float sum = 0;

        for (int k = -RADIUS; k <= RADIUS; k++) sum += tile[ty][shared_x + k] * kernel[RADIUS + k];

        output[y * width + x] = sum;
    }
}

__global__ void conv_vertical(float* input, float* output, float* kernel, int width, int height)
{
    __shared__ float tile[BLOCK_SIZE + 2 * RADIUS][BLOCK_SIZE];

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int x = blockIdx.x * BLOCK_SIZE + tx;
    int y = blockIdx.y * BLOCK_SIZE + ty;

    int shared_y = ty + RADIUS;

    if (x < width && y < height)
        tile[shared_y][tx] = input[y * width + x];
    else
        tile[shared_y][tx] = 0;

    if (ty < RADIUS)
    {
        int top = y - RADIUS;
        int bottom = y + BLOCK_SIZE;

        tile[ty][tx] = (top >= 0) ? input[top * width + x] : 0;

        tile[ty + BLOCK_SIZE + RADIUS][tx] = (bottom < height) ? input[bottom * width + x] : 0;
    }

    __syncthreads();

    if (x < width && y < height)
    {
        float sum = 0;

        for (int k = -RADIUS; k <= RADIUS; k++) sum += tile[shared_y + k][tx] * kernel[RADIUS + k];

        output[y * width + x] = sum;
    }
}