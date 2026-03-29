#define TILE 16
#define SCALE 5

/**TODO : Dynamic shared memory size */

__global__ void downsample(
    unsigned char *input,
    unsigned char *output,
    int width, int height,
    int channels,
    int scale)
{
    int scaled_height = height / scale;
    int scaled_width = width / scale;

    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int out_x = blockIdx.x * TILE + tx;
    int out_y = blockIdx.y * TILE + ty;
    __shared__ unsigned char tile[TILE * SCALE * TILE * SCALE * 4];

    int tile_size = TILE * scale;
    for (int i = ty; i < tile_size; i += blockDim.y)
    {
        for (int j = tx; j < tile_size; j += blockDim.x)
        {
            int gx = blockIdx.x * TILE * scale + j;
            int gy = blockIdx.y * TILE * scale + i;

            if (gx < width && gy < height)
            {
                for (int c = 0; c < channels; c++)
                {
                    int global_idx = (gy * width + gx) * channels + c;
                    int local_idx = (i * tile_size + j) * channels + c;

                    tile[local_idx] = input[global_idx];
                }
            }
        }
    }

    __syncthreads();

    if (out_x < scaled_width && out_y < scaled_height)
    {

        int base_y = ty * scale;
        int base_x = tx * scale;

        int out_idx_base = (out_y * scaled_width + out_x) * channels;

        for (int c = 0; c < channels; c++)
        {

            int sum = 0;

            for (int i = 0; i < scale; i++)
            {
                int row_offset = (base_y + i) * tile_size;

                for (int j = 0; j < scale; j++)
                {
                    int idx = (row_offset + (base_x + j)) * channels + c;
                    sum += tile[idx];
                }
            }

            output[out_idx_base + c] = sum / (scale * scale);
        }
    }
}