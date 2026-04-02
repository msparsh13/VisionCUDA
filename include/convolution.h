#pragma once
#include<kernels.hpp>
#include<padding.hpp>

void convolve(
unsigned char* h_input,
unsigned char* h_output,
int width,
int height,
KernelType kernelType,
PaddingType padding);

void convolve_tiled(float* d_input,
                    float* d_output,
                    int width,
                    int height,
                    int channels,
                    KernelType kernelType,
                    PaddingType padding);


void separable_convolution(unsigned char* d_input,
                           unsigned char* d_output,
                           unsigned char* d_temp,
                           int width,
                           int height,
                           int channels,
                           KernelType kernelType,
                           PaddingType padding,
                           int kSize);

void convolve_img(
    unsigned char* h_input,
    unsigned char* h_output,
    int width,
    int height,
    KernelType kernelType,
    PaddingType padding);