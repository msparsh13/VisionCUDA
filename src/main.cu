/**
 * IGNORE THE MAIN CURRENTLY ITS JUST A PLAY GROUND
 */

#include <iostream>
#define STB_IMAGE_IMPLEMENTATION
#include "../include/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../include/stb_image_write.h"

#include "../include/convolution.h"
#include "./common/kernelFactory.cpp"
#include <cuda_runtime.h>

#include "../include/histogram.h"
#include "../include/affine.h"
#include "../include/grayscale.h"
#include "../include/binarizing.h"

#include "../include/dilation.h"
#include <iostream>

void print_histogram_rgb(unsigned char *img, int width, int height)
{
    int N = width * height;

    unsigned int histR[256] = {0};
    unsigned int histG[256] = {0};
    unsigned int histB[256] = {0};

    for (int i = 0; i < N; i++)
    {
        histR[img[3 * i + 0]]++;
        histG[img[3 * i + 1]]++;
        histB[img[3 * i + 2]]++;
    }

    std::cout << "Red Channel Histogram:\n";
    for (int i = 0; i < 256; i++)
        std::cout << i << ":" << histR[i] << " ";
    std::cout << "\n\n";

    std::cout << "Green Channel Histogram:\n";
    for (int i = 0; i < 256; i++)
        std::cout << i << ":" << histG[i] << " ";
    std::cout << "\n\n";

    std::cout << "Blue Channel Histogram:\n";
    for (int i = 0; i < 256; i++)
        std::cout << i << ":" << histB[i] << " ";
    std::cout << "\n\n";
}
void pyramid_laplacian(
    unsigned char *h_input,
    std::vector<unsigned char *> &laplacian,
    int width,
    int height,
    int kSize,
    int scale,
    int channels,
    int levels);

void pyramid_gaussian(
    unsigned char *h_input,
    std::vector<unsigned char *> &outputs,
    int width,
    int height,
    int kSize,
    int scale,
    int channels,
    int levels);

__global__ void add_img(unsigned char *A, unsigned char *B, unsigned char *out, int width, int height, int channels);
__global__ void conv_vertical(unsigned char *, unsigned char *, float *, int, int, int);
__global__ void conv_horizontal(unsigned char *, unsigned char *, float *, int, int, int);
__global__ void upsample(unsigned char *, unsigned char *, int, int, int, int);
__global__ void subtract_img(unsigned char *, unsigned char *, unsigned char *, int, int, int);
__global__ void scale_img(unsigned char *, int, int, int, int);
int main(int argc, char **argv)
{
    if (argc < 2)
    {
        std::cout << "Usage: ./app input.png\n";
        return 0;
    }

    int width, height, channels;
    unsigned char *img = stbi_load(argv[1], &width, &height, &channels, 3);
    channels = 3;

    int levels = 4;
    int scale = 2;

    std::vector<unsigned char *> gaussian;
    std::vector<unsigned char *> laplacian;

    pyramid_gaussian(img, gaussian, width, height, 3, scale, channels, levels);
    pyramid_laplacian(img, laplacian, width, height, 3, scale, channels, levels);

    // ---------- SAVE GAUSSIAN ----------
    int curr_w = width;
    int curr_h = height;

    for (int i = 0; i < gaussian.size(); i++)
    {
        char name[50];
        sprintf(name, "./output/gaussian_%d.png", i);

        stbi_write_png(name, curr_w, curr_h, 3, gaussian[i], curr_w * 3);

        curr_w /= scale;
        curr_h /= scale;
    }

    // ---------- SAVE LAPLACIAN ----------
    curr_w = width;
    curr_h = height;

    for (int i = 0; i < laplacian.size(); i++)
    {
        char name[50];
        sprintf(name, "./output/laplacian_%d.png", i);

        stbi_write_png(name, curr_w, curr_h, 3, laplacian[i], curr_w * 3);

        curr_w /= scale;
        curr_h /= scale;
    }

    // ---------- VERIFY RECONSTRUCTION ----------
    curr_w = width;
    curr_h = height;

    dim3 block(16, 16);

    float *d_kernel_X;
    float *d_kernel_Y;

    int kSize =3;

    auto kernelVec_X = getKernel1D_X(KernelType::GAUSSIAN, kSize);
    auto kernelVec_Y = getKernel1D_Y(KernelType::GAUSSIAN, kSize);

    cudaMalloc(&d_kernel_X, kSize * sizeof(float));
    cudaMemcpy(d_kernel_X, kernelVec_X.data(), kSize * sizeof(float), cudaMemcpyHostToDevice);

    cudaMalloc(&d_kernel_Y, kSize * sizeof(float));
    cudaMemcpy(d_kernel_Y, kernelVec_Y.data(), kSize * sizeof(float), cudaMemcpyHostToDevice);

    for (int i = 0; i < levels; i++)
    {
        int next_w = curr_w / scale;
        int next_h = curr_h / scale;

        unsigned char *d_small, *d_up, *d_temp, *d_blur, *d_lap, *d_out;

        size_t small_size = next_w * next_h * channels * sizeof(unsigned char);
        size_t big_size = curr_w * curr_h * channels * sizeof(unsigned char);

        cudaMalloc(&d_small, small_size);
        cudaMalloc(&d_up, big_size);
        cudaMalloc(&d_temp, big_size);
        cudaMalloc(&d_blur, big_size);
        cudaMalloc(&d_lap, big_size);
        cudaMalloc(&d_out, big_size);

        cudaMemcpy(d_small, gaussian[i + 1],
                   next_w * next_h * channels,
                   cudaMemcpyHostToDevice);

        cudaMemcpy(d_lap, laplacian[i],
                   curr_w * curr_h * channels,
                   cudaMemcpyHostToDevice);

        dim3 grid((curr_w + 15) / 16, (curr_h + 15) / 16);

        // upsample G[i+1]
        // upsample
        upsample<<<grid, block>>>(d_small, d_up, next_w, next_h, scale, channels);

        // blur
        conv_horizontal<<<grid, block>>>(d_up, d_temp, d_kernel_X, curr_w, curr_h, channels);
        conv_vertical<<<grid, block>>>(d_temp, d_blur, d_kernel_Y, curr_w, curr_h, channels);

        // scale
        scale_img<<<grid, block>>>(d_blur, curr_w, curr_h, channels, scale * scale);

        // add laplacian
        add_img<<<grid, block>>>(d_blur, d_lap, d_out, curr_w, curr_h, channels);

        cudaDeviceSynchronize();

        unsigned char *h_out = new unsigned char[curr_w * curr_h * channels];
        cudaMemcpy(h_out, d_out, curr_w * curr_h * channels,
                   cudaMemcpyDeviceToHost);

        char name[50];
        sprintf(name, "./output/reconstruct_%d.png", i);

        stbi_write_png(name, curr_w, curr_h, 3, h_out, curr_w * 3);

        cudaFree(d_small);
        cudaFree(d_up);
        cudaFree(d_lap);
        cudaFree(d_out);

        curr_w /= scale;
        curr_h /= scale;
    }
    cudaFree(d_kernel_X);
    cudaFree(d_kernel_Y);
    std::cout << "Done\n";
    return 0;
}
