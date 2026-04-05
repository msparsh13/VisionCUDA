#define TILE 16;
#include<matrix.h>
#include<matOp.hpp>

/**
 * TODO THINK ABOUT IT LATER
 */

void MatMulOp::apply(unsigned char*& d_data,
                     unsigned char* d_temp,
                     int& width,
                     int& height,
                     int& channels)
{

    float* d_A = reinterpret_cast<float*>(d_data);

    float* d_C;
    cudaMalloc(&d_C, M * N * sizeof(float));
    mul(d_A, d_B, d_C, M, K, N);
    cudaFree(d_data);
    d_data = reinterpret_cast<unsigned char*>(d_C);

    width = N;
    height = M;
    channels = 1; 
}