__global__ void kernel_binary(unsigned char* img, unsigned char* out, int width, int height,
                              int thresh)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < width && y < height)
    {
        int rgb_idx = (y * width + x) * 3;
        int binary_idx = y * width + x;

        unsigned char r = img[rgb_idx];
        unsigned char g = img[rgb_idx + 1];
        unsigned char b = img[rgb_idx + 2];

        out[binary_idx] = 0.299f * r + 0.587f * g + 0.114f * b >= thresh ? 255 : 0;
    }
}