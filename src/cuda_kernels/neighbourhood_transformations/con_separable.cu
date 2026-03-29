#define RADIUS 1
#define BLOCK_SIZE 16

__global__ void conv_horizontal(
    unsigned char *input,
    unsigned char *output,
    float *kernel,
    int width,
    int height,
    int channels)
{
    __shared__ float tile[BLOCK_SIZE][BLOCK_SIZE + 2 * RADIUS][4];

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int x = blockIdx.x * BLOCK_SIZE + tx;
    int y = blockIdx.y * BLOCK_SIZE + ty;

    int shared_x = tx + RADIUS;

    // load center pixel
    for (int c = 0; c < channels; c++) {
        if (x < width && y < height)
            tile[ty][shared_x][c] = input[(y * width + x) * channels + c];
        else
            tile[ty][shared_x][c] = 0;
    }

    // halo
    if (tx < RADIUS)
    {
        int left = x - RADIUS;
        int right = x + BLOCK_SIZE;

        for (int c = 0; c < channels; c++) {
            tile[ty][tx][c] =
                (left >= 0 && y < height) ? input[(y * width + left) * channels + c] : 0;

            tile[ty][tx + BLOCK_SIZE + RADIUS][c] =
                (right < width && y < height) ? input[(y * width + right) * channels + c] : 0;
        }
    }

    __syncthreads();

    if (x < width && y < height)
    {
        for (int c = 0; c < channels; c++)
        {
            float sum = 0;

            for (int k = -RADIUS; k <= RADIUS; k++)
                sum += tile[ty][shared_x + k][c] * kernel[RADIUS + k];

            sum = fminf(fmaxf(sum, 0.0f), 255.0f);
            output[(y * width + x) * channels + c] = (unsigned char)(sum);
        }
    }
}

__global__ void conv_vertical(
    unsigned char *input,
    unsigned char *output,
    float *kernel,
    int width,
    int height,
    int channels)
{
    __shared__ float tile[BLOCK_SIZE + 2 * RADIUS][BLOCK_SIZE][4]; 

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int x = blockIdx.x * BLOCK_SIZE + tx;
    int y = blockIdx.y * BLOCK_SIZE + ty;

    int shared_y = ty + RADIUS;

    // 🔹 Load center pixels
    for (int c = 0; c < channels; c++)
    {
        if (x < width && y < height)
            tile[shared_y][tx][c] = input[(y * width + x) * channels + c];
        else
            tile[shared_y][tx][c] = 0;
    }

    // 🔹 Load halo (top & bottom)
    if (ty < RADIUS)
    {
        int top = y - RADIUS;
        int bottom = y + BLOCK_SIZE;

        for (int c = 0; c < channels; c++)
        {
            // top halo
            tile[ty][tx][c] =
                (top >= 0 && x < width) ? input[(top * width + x) * channels + c] : 0;

            // bottom halo
            tile[ty + BLOCK_SIZE + RADIUS][tx][c] =
                (bottom < height && x < width) ? input[(bottom * width + x) * channels + c] : 0;
        }
    }

    __syncthreads();

    // 🔹 Convolution
    if (x < width && y < height)
    {
        for (int c = 0; c < channels; c++)
        {
            float sum = 0.0f;

            for (int k = -RADIUS; k <= RADIUS; k++)
            {
                sum += tile[shared_y + k][tx][c] * kernel[RADIUS + k];
            }

            // clamp to [0,255]
            sum = fminf(fmaxf(sum, 0.0f), 255.0f);

            output[(y * width + x) * channels + c] = (unsigned char)(sum);
        }
    }
}