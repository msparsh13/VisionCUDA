#define RADIUS 1
#define BLOCK_SIZE 16

// -------------------------
// HORIZONTAL CONVOLUTION
// -------------------------
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

    // 🔹 Load full horizontal neighborhood (center + halo)
    for (int k = -RADIUS; k <= RADIUS; k++)
    {
        int nx = x + k;
        int sx = shared_x + k;

        for (int c = 0; c < channels; c++)
        {
            if (nx >= 0 && nx < width && y < height)
                tile[ty][sx][c] = input[(y * width + nx) * channels + c];
            else
                tile[ty][sx][c] = 0.0f;
        }
    }

    __syncthreads();

    // 🔹 Convolution
    if (x < width && y < height)
    {
        int base = (y * width + x) * channels;

        for (int c = 0; c < channels; c++)
        {
            float sum = 0.0f;

            for (int k = -RADIUS; k <= RADIUS; k++)
            {
                sum += tile[ty][shared_x + k][c] * kernel[RADIUS + k];
            }

            sum = fminf(fmaxf(sum, 0.0f), 255.0f);
            output[base + c] = (unsigned char)(sum);
        }
    }
}


// -------------------------
// VERTICAL CONVOLUTION
// -------------------------
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

    // 🔹 Load full vertical neighborhood (center + halo)
    for (int k = -RADIUS; k <= RADIUS; k++)
    {
        int ny = y + k;
        int sy = shared_y + k;

        for (int c = 0; c < channels; c++)
        {
            if (ny >= 0 && ny < height && x < width)
                tile[sy][tx][c] = input[(ny * width + x) * channels + c];
            else
                tile[sy][tx][c] = 0.0f;
        }
    }

    __syncthreads();

    // 🔹 Convolution
    if (x < width && y < height)
    {
        int base = (y * width + x) * channels;

        for (int c = 0; c < channels; c++)
        {
            float sum = 0.0f;

            for (int k = -RADIUS; k <= RADIUS; k++)
            {
                sum += tile[shared_y + k][tx][c] * kernel[RADIUS + k];
            }

            sum = fminf(fmaxf(sum, 0.0f), 255.0f);
            output[base + c] = (unsigned char)(sum);
        }
    }
}