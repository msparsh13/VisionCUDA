#include <iostream>
#include <vector>
#include <cuda_runtime.h>

#define STB_IMAGE_IMPLEMENTATION
#include "../include/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../include/stb_image_write.h"

#include "pipeline.hpp"
#include "convOp.hpp"
#include "kernels.hpp"
#include "padding.hpp"

int main(int argc, char **argv)
{
    int width, height, channels;

    if (argc < 2)
    {
        std::cout << "Usage: ./app input.png\n";
        return 0;
    }

    // 🔹 Load image (force RGB)
    unsigned char *h_img = stbi_load(argv[1], &width, &height, &channels, 3);
    channels = 3;

    if (!h_img)
    {
        std::cout << "Failed to load image\n";
        return -1;
    }

    std::cout << "Loaded: " << width << "x" << height
              << " channels: " << channels << "\n";

    // 🔹 Allocate GPU memory
    unsigned char *d_data;
    int size = width * height * channels;

    cudaMalloc(&d_data, size);
    cudaMemcpy(d_data, h_img, size, cudaMemcpyHostToDevice);

    // 🔹 Pipeline
    Pipeline p;
    p.init(width, height, channels);

    // Example: Gaussian blur
    p.add(new ConvolutionOp(KernelType::GAUSSIAN, PaddingType::ZERO));

    p.run(d_data, width, height, channels);

    // 🔹 Copy back
    unsigned char *h_out = new unsigned char[size];
    cudaMemcpy(h_out, d_data, size, cudaMemcpyDeviceToHost);

    // 🔹 Save output
    stbi_write_png("output.png",
                   width,
                   height,
                   channels,
                   h_out,
                   width * channels);

    std::cout << "Saved output.png\n";

    // 🔹 Cleanup
    cudaFree(d_data);
    stbi_image_free(h_img);
    delete[] h_out;

    return 0;
}