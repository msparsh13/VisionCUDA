__global__ void kernel_log(unsigned char* img, int size, float scale)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < size)
    {
        float r = img[idx];
        float s = scale * logf(1.0f + r);

        if (s > 255) s = 255;

        img[idx] = (unsigned char)s;
    }
}
