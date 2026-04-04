__global__ void upsample(unsigned char* input , unsigned char* output , int width , int height , int scale , int channels)
;


void upsample(unsigned char* d_in,
                    unsigned char* d_out,
                    int width,
                    int height,
                    int scale,
                    int channels)
{
    int new_w = width * scale;
    int new_h = height * scale;

    dim3 block(16, 16);
    dim3 grid((new_w + block.x - 1) / block.x,
              (new_h + block.y - 1) / block.y);

    upsample<<<grid, block>>>(d_in, d_out, width, height, scale, channels);
    cudaDeviceSynchronize();
}