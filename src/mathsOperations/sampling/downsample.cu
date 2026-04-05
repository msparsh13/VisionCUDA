
__global__ void downsample(
    unsigned char *input,
    unsigned char *output,
    int width, int height,
    int channels,
    int scale);

void downsamplefunc(unsigned char* d_in,
                      unsigned char* d_out,
                      int width,
                      int height,
                      int scale,
                      int channels)
{
    int new_w = width / scale;
    int new_h = height / scale;

    dim3 block(16, 16);
    dim3 grid((new_w + 16 - 1) / 16,
              (new_h + 16 - 1) / 16);

    downsample<<<grid, block>>>(d_in, d_out, width, height, channels, scale);
    cudaDeviceSynchronize();
}