__global__ void kernel_brightness(unsigned char* img, int size, float alpha, float beta);

void brightness(unsigned char* d_img, int size, float alpha, float beta)
{
    int blockSize = 256;
    int numBlocks = (size + blockSize - 1) / blockSize;

    kernel_brightness<<<numBlocks, blockSize>>>(d_img, size, alpha, beta);

    cudaDeviceSynchronize();
}