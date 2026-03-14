__global__ void kernel_log(unsigned char* img, int size, float scale);

void log_transform(unsigned char* d_img, int size, float scale)
{
    int blockSize = 256;
    int numBlocks = (size + blockSize - 1) / blockSize;

    kernel_log<<<numBlocks, blockSize>>>(d_img, size, scale);

    cudaDeviceSynchronize();
}