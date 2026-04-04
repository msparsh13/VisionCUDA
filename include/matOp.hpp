#pragma once
#include "Operations.hpp"

class AddOp : public Operation
{
public:
    AddOp(unsigned char* other) : d_other(other) {}

    void apply(unsigned char*& d_data,
               unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    unsigned char* d_other; // second image
};


class SubtractOp : public Operation
{
public:
    SubtractOp(unsigned char* other) : d_other(other) {}

    void apply(unsigned char*& d_data,
               unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    unsigned char* d_other;
};


class ScaleOp : public Operation
{
public:
    ScaleOp(int factor) : factor(factor) {}

    void apply(unsigned char*& d_data,
               unsigned char* d_temp,
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
               unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    float* d_B;   
    int M, K, N;  
};