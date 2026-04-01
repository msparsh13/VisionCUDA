
#define TILE 16

__global__ void dilation_tiled( unsigned char *input,
    unsigned char *output, int width, int height,
                           int kSize);

__global__ void erosion_tiled( unsigned char *input,
    unsigned char *output, int width, int height,
                           int kSize);

// void opening(unsigned char* d_input,
//              unsigned char* d_output,
//              int width, int height,
//              int kSize)
// {
//     dim3 block(TILE, TILE);
//     dim3 grid((width + TILE - 1) / TILE, (height + TILE - 1) / TILE);

//     size_t sharedMem = (TILE + 2 * (kSize / 2)) * (TILE + 2 * (kSize / 2)) * sizeof(unsigned char);

//     unsigned char* d_temp;
//     cudaMalloc(&d_temp, width * height * sizeof(unsigned char));

//     erosion_tiled<<<grid, block, sharedMem>>>(d_input, d_temp, width, height, kSize);
//     cudaDeviceSynchronize();

//     dilation_tiled<<<grid, block, sharedMem>>>(d_temp, d_output, width, height, kSize);
//     cudaDeviceSynchronize();

//     cudaFree(d_temp);
// }