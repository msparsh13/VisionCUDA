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


int main(int argc, char** argv)
{
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " input.png\n";
        return 0;
    }

    const char* inputFile = argv[1];

    int width, height, channels;

    // Load image as RGB (3 channels)
    unsigned char* img = stbi_load(inputFile, &width, &height, &channels, 3);
    if (!img) {
        std::cerr << "Failed to load image\n";
        return -1;
    }
    std::cout << "Loaded: " << width << " x " << height << " x 3\n";

    size_t rgbSize = width * height * 3 * sizeof(unsigned char);
    size_t graySize = width * height * sizeof(unsigned char);

    // Allocate GPU memory
    unsigned char *d_img, *d_binary, *d_dilated;
    cudaMalloc(&d_img, rgbSize);
    cudaMalloc(&d_binary, graySize);
    cudaMalloc(&d_dilated, graySize);

    // Copy RGB image to GPU
    cudaMemcpy(d_img, img, rgbSize, cudaMemcpyHostToDevice);

    // ------------------ GPU Pipeline ------------------
    // 1️⃣ Binary thresholding
    binary(d_img, d_binary, width, height, 100);

    // 2️⃣ Dilation (kernel size = 3)
    opening(d_binary, d_dilated, width, height, 3);

    // Copy result back to host
    unsigned char* output = new unsigned char[width * height];
    cudaMemcpy(output, d_dilated, graySize, cudaMemcpyDeviceToHost);

    // Save output (1-channel)
    const char* outputFile = "./output/binary_dilated.png";
    if (!stbi_write_png(outputFile, width, height, 1, output, width)) {
        std::cerr << "Failed to save image\n";
    } else {
        std::cout << "Saved: " << outputFile << "\n";
    }

    // ------------------ Cleanup ------------------
    cudaFree(d_img);
    cudaFree(d_binary);
    cudaFree(d_dilated);
    delete[] output;
    stbi_image_free(img);

    return 0;
}