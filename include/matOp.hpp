#pragma once
#include "Operations.hpp"


struct GpuImage {
    unsigned char* data;
    int w, h, c;
};
class AddOp : public Operation
{
public:
    AddOp(GpuImage other): other(other){};

    void apply(unsigned char*& d_data,
               unsigned char*& d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    GpuImage other;
};

class SubtractOp : public Operation
{
public:
     SubtractOp(GpuImage other): other(other){};

     void apply(unsigned char*& d_data,
               unsigned char*& d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    GpuImage other;
};

class ScaleOp : public Operation
{
public:
    ScaleOp(int factor) : factor(factor) {}

    void apply(unsigned char*& d_data,
               unsigned char*&d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    int factor;
};

class MatMulOp : public Operation
{
public:
    MatMulOp(float* d_B, int M, int K, int N)
        : d_B(d_B), M(M), K(K), N(N) {}

    void apply(unsigned char*& d_data,
               unsigned char*&d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    float* d_B;   
    int M, K, N;  
};