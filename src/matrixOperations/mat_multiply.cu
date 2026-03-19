#define TILE 16
// currently making for 16 tile size
__global__ void matMultiply(
    float *A,
    float *B,
    float *C,
    int N, int K, int M, int tile = 3)
{

    // int col = blockIdx.x * blockDim.x + threadIdx.x;
    // int row = blockIdx.y * blockDim.y + threadIdx.y;

    // float sum = 0.0f;

    // if (row < M && col < N)
    // {
    //     for (int i = 0; i < K; i++)
    //     {
    //         sum += A[row * K + i] * B[i * N + col];
    //     }

    //     C[row * N + col] = sum;
    // }

    /**
     * might be having some naming convention problem but im consider block size as  non overlapping and tile size [used in conv]
     * as overlapping though they might be named differently
     */
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = blockIdx.y * blockDim.y + ty;
    int col = blockIdx.x * blockDim.x + tx;

    extern __shared__ float shared[];

    float *tileA = shared;
    float *tileB = shared + (TILE * TILE);
    float sum = 0;
    for (int i = 0; i < (K + TILE - 1) / TILE /*ceil*/; ++i)
    {

        if (row < N && i * TILE + tx < K)
        {
            tileA[i * TILE + tx] = A[row * K + i * TILE + tx];
        }
        else
        {
            tileA[i * TILE + tx] = 0;
        }
        if (col < M && i * TILE + ty < K)
        {
            tileB[i * TILE + ty] = B[col + (i * TILE + ty) * M];
        }
        else
        {
            tileB[i * TILE + ty] = 0;
        }
    

    __syncthreads();

    for (int k = 0; k < TILE; k++)
    {
        sum += tileA[ty * TILE + k] * tileB[k * TILE + tx];
    }
}

    __syncthreads();

    if (row < N && col < M)
    {
        C[row * M + col] = sum;
    }

}