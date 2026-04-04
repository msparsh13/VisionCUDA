__global__ void scale_img(
    unsigned char* img,
    int width,
    int height,
    int channels,
    int factor)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    for (int c = 0; c < channels; c++)
    {
        int idx = (y * width + x) * channels + c;

        int val = img[idx] * factor;
        val = max(0, min(255, val));
        img[idx] = (unsigned char)val;
    }
}