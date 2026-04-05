#include <iostream>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "pipeline.hpp"
#include "HistogramEqlOp.hpp"
#include "brightnessOp.hpp"

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

    // 🔹 Allocate GPU memory (FIXED: use bytes)
    int size = width * height * channels;
    unsigned char *d_data;

    cudaMalloc(&d_data, size * sizeof(unsigned char));
    cudaMemcpy(d_data, h_img, size * sizeof(unsigned char), cudaMemcpyHostToDevice);

    // 🔹 Pipeline
    Pipeline p;
    p.init(width, height, channels);

    float alpha = 1.2f;  // contrast
int beta = 30;       // brightness

p.add(new BrightnessOp(alpha, beta));

    p.run(d_data, width, height, channels);

    // 🔴 IMPORTANT: wait for GPU to finish
    cudaDeviceSynchronize();

    // 🔹 Copy back
    unsigned char *h_out = new unsigned char[size];
    cudaMemcpy(h_out, d_data, size * sizeof(unsigned char), cudaMemcpyDeviceToHost);

    // 🔹 Save output
    stbi_write_png("hist_eq.png",
                   width,
                   height,
                   channels,
                   h_out,
                   width * channels);

    std::cout << "Saved hist_eq.png\n";

    // 🔹 Cleanup
    cudaFree(d_data);
    stbi_image_free(h_img);
    delete[] h_out;

    return 0;
}