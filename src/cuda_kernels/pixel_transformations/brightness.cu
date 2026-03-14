__global__ void kernel_brightness(unsigned char* img, int size, float alpha, float beta)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < size) img[idx] = min(255, (int)ceil(alpha * img[idx] + beta));
}
