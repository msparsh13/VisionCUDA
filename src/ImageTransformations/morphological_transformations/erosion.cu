
__global__ void erosion_tiled(unsigned char *input,
                              unsigned char *output, int width, int height,
                              int kSize);
void erosion(unsigned char *d_img,
             unsigned char *d_out,
             int width,
             int height,
             int kSize)
{
    dim3 block(16, 16);

    dim3 grid((width + block.x - 1) / block.x,
              (height + block.y - 1) / block.y);

    int radius = kSize / 2;

    size_t sharedMem =
        (block.x + 2 * radius) *
        (block.y + 2 * radius) *
        sizeof(unsigned char);

    erosion_tiled<<<grid, block, sharedMem>>>(
        d_img,
        d_out,
        width,
        height,
        kSize);
}