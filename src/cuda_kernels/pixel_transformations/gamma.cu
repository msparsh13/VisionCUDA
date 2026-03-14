__global__ void kernel_gamma(unsigned char* img, int size, float gamma)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < size)
    {
        float r = img[idx] / 255.0f;
        float s = powf(r, gamma) * 255.0f;

        img[idx] = (unsigned char)s;
    }
}
