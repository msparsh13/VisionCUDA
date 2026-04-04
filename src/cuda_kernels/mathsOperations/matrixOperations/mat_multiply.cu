#define TILE 16

__global__ void multiply_cuda(
    float *A,
    float *B,
    float *C,
    int M, int K, int N)   // A: MxK, B: KxN, C: MxN
{
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    int row = blockIdx.y * TILE + ty;
    int col = blockIdx.x * TILE + tx;

    extern __shared__ float shared[];

    float *tileA = shared;
    float *tileB = shared + (TILE * TILE);

    float sum = 0.0f;

    for (int t = 0; t < (K + TILE - 1) / TILE; t++)
    {
        // Load A tile
        if (row < M && (t * TILE + tx) < K)
            tileA[ty * TILE + tx] = A[row * K + t * TILE + tx];
        else
            tileA[ty * TILE + tx] = 0.0f;

        // Load B tile
        if (col < N && (t * TILE + ty) < K)
            tileB[ty * TILE + tx] = B[(t * TILE + ty) * N + col];
        else
            tileB[ty * TILE + tx] = 0.0f;

        __syncthreads();

        for (int k = 0; k < TILE; k++)
        {
            sum += tileA[ty * TILE + k] * tileB[k * TILE + tx];
        }

        __syncthreads();
    }

    if (row < M && col < N)
    {
        C[row * N + col] = sum;
    }
}