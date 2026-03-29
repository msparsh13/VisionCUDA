__global__ void subtract_img(
    unsigned char* A,
    unsigned char* B,
    unsigned char* out,
    int width,
    int height,
    int channels)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    for (int c = 0; c < channels; c++)
    {
        int idx = (y * width + x) * channels + c;

        int val = ((int)A[idx] - (int)B[idx]) + 128;

        out[idx] = (unsigned char)val;
    }

}