#include <iostream>
#include <vector>
#include <cuda_runtime.h>

#define STB_IMAGE_IMPLEMENTATION
#include "../include/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../include/stb_image_write.h"

#include "pipeline.hpp"
#include "grayscaleOp.hpp"
#include "binarizeOp.hpp"
#include "affineOp.hpp"
#include "affine.h"

int main(int argc, char **argv)
{

    int width, height, channels;

    if (argc < 2)
    {
        std::cout << "Usage: ./app input.png\n";
        return 0;
    }
    // 🔹 Load image (CPU)
    unsigned char *h_img = stbi_load(argv[1], &width, &height, &channels, 3);

    if (!h_img)
    {
        std::cout << "Failed to load image\n";
        return -1;
    }

    std::cout << "Loaded: " << width << "x" << height << " channels: " << channels << "\n";

    unsigned char *d_data;
    int size = width * height * channels * sizeof(unsigned char);

    cudaMalloc(&d_data, size);
    cudaMemcpy(d_data, h_img, size, cudaMemcpyHostToDevice);

    Pipeline p;
    p.init(width, height, channels);
    p.add(new GrayscaleOp(GrayMode::SINGLE));
    p.add(new BinarizeOp(85));
    AffineOp *aff = new AffineOp();

    aff->addRotate(30);
    aff->addTranslate(50, 30);
    aff->addShear(0.2f, 0.0f);

    p.add(aff);
    p.run(d_data, width, height, channels);

    int out_channels = 1;

    int out_size = width * height * out_channels * sizeof(unsigned char);
    unsigned char *h_out = new unsigned char[width * height * out_channels];

    cudaMemcpy(h_out, d_data, out_size, cudaMemcpyDeviceToHost);

    // 🔹 Save output
    stbi_write_png("output.png", width, height, out_channels, h_out, width * out_channels);

    std::cout << "Saved output.png\n";

    // 🔹 Cleanup
    cudaFree(d_data);
    stbi_image_free(h_img);
    delete[] h_out;

    return 0;
}