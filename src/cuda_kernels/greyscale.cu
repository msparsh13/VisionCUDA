__global__ void kernel_grayscale_triple(unsigned char* img,
                          int width,
                          int height)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if(x < width && y < height)
    {
        int idx = (y * width + x) * 3;

        unsigned char r = img[idx];
        unsigned char g = img[idx+1];
        unsigned char b = img[idx+2];

        unsigned char gray =
            0.299f*r + 0.587f*g + 0.114f*b;

        img[idx]   = gray;
        img[idx+1] = gray;
        img[idx+2] = gray;
    }
}


__global__ void kernel_grayscale_single(unsigned char* img,
                             unsigned char* out,
                             int width,
                             int height)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if(x < width && y < height)
    {
        int rgb_idx = (y * width + x) * 3;
        int gray_idx = y * width + x;

        unsigned char r = img[rgb_idx];
        unsigned char g = img[rgb_idx+1];
        unsigned char b = img[rgb_idx+2];

        out[gray_idx] =
            0.299f*r + 0.587f*g + 0.114f*b;
    }
}