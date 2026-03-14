__global__ void kernel_gamma(unsigned char* img, int size, float gamma);

void gamma_transform(unsigned char* d_img, int size, float gamma)
{
    int blockSize = 256;
    int numBlocks = (size + blockSize - 1) / blockSize;

    kernel_gamma<<<numBlocks, blockSize>>>(d_img, size, gamma);

    cudaDeviceSynchronize();
}