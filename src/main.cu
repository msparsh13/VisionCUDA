#define STB_IMAGE_IMPLEMENTATION
#include "../include/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../include/stb_image_write.h"
#include "../include/grayscale.h"


#include <iostream>
#include <cuda_runtime.h>

int main(int argc, char** argv)
{
    if(argc < 3)
    {
        std::cout << "Usage: program input.png output.png\n";
        return 0;
    }

    const char* inputFile  = argv[1];
    const char* outputFile = argv[2];

    int width, height, channels;

    // load image
    unsigned char* img =
        stbi_load(inputFile, &width, &height, &channels, 0);

    if(!img)
    {
        std::cout << "Failed to load image\n";
        return -1;
    }

    std::cout << "Loaded image\n";
    std::cout << "Width: " << width << "\n";
    std::cout << "Height: " << height << "\n";
    std::cout << "Channels: " << channels << "\n";

    int rgb_size = width * height * channels;
    int gray_size = width * height;

    // allocate GPU memory
    unsigned char* d_img;
    unsigned char* d_gray;

    cudaMalloc(&d_img, rgb_size);
    cudaMalloc(&d_gray, gray_size);

    // copy RGB image to GPU
    cudaMemcpy(d_img, img, rgb_size, cudaMemcpyHostToDevice);

    // run grayscale transformation
    grayscale_single(d_img, d_gray, width, height);

    // allocate host memory for grayscale
    unsigned char* gray_img = new unsigned char[gray_size];

    // copy result back
    cudaMemcpy(gray_img, d_gray, gray_size, cudaMemcpyDeviceToHost);

    // save grayscale image
    stbi_write_png(outputFile,
                   width,
                   height,
                   1,        // single channel
                   gray_img,
                   width);

    std::cout << "Output saved to " << outputFile << "\n";

    cudaFree(d_img);
    cudaFree(d_gray);

    delete[] gray_img;
    stbi_image_free(img);

    return 0;
}