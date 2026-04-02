__global__ void uchar_to_float(unsigned char* in, float* out, int size)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size)
        out[i] = (float)in[i];
}

__global__ void float_to_uchar(float* in, unsigned char* out, int size)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size)
    {
        float v = in[i];
        v = fminf(fmaxf(v, 0.0f), 255.0f);
        out[i] = (unsigned char)v;
    }
}