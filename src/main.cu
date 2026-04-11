#include <iostream>

#include "grayscaleOp.hpp"
#include "affineOp.hpp"
#include "convOp.hpp"
#include "convolution.h"
#include <iostream>
#include <string>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

#include "pipeline.hpp"
#include "parserHelper.hpp"   // 👈 your parser

int main(int argc, char **argv)
{
    int width, height, channels;

    // ✅ Now require 3 args
    if (argc < 4)
    {
        std::cout << "Usage: ./app input.png output.png config.json\n";
        return 0;
    }

    std::string inputPath  = argv[1];
    std::string outputPath = argv[2];
    std::string jsonPath   = argv[3];

    // 🔹 Load image (force RGB)
    unsigned char *h_img = stbi_load(inputPath.c_str(), &width, &height, &channels, 3);
    channels = 3;

    if (!h_img)
    {
        std::cout << "Failed to load image\n";
        return -1;
    }

    std::cout << "Loaded: " << width << "x" << height
              << " channels: " << channels << "\n";

    // 🔹 Allocate GPU memory
    int size = width * height * channels;
    unsigned char *d_data;

    cudaMalloc(&d_data, size * sizeof(unsigned char));
    cudaMemcpy(d_data, h_img, size * sizeof(unsigned char), cudaMemcpyHostToDevice);

    // 🔹 Pipeline
    Pipeline p;
    p.init(width, height, channels);

    // 🔥 BUILD FROM JSON (instead of hardcoded ops)
    buildPipelineFromJSON(jsonPath, p);

    // -----------------------------
    // 🚀 RUN PIPELINE
    // -----------------------------
    p.run(d_data, width, height, channels);

    cudaDeviceSynchronize();

    // 🔹 Copy back
    unsigned char *h_out = new unsigned char[size];
    cudaMemcpy(h_out, d_data, size * sizeof(unsigned char), cudaMemcpyDeviceToHost);

    // 🔹 Save output (auto-detect extension)
    if (outputPath.find(".png") != std::string::npos)
    {
        stbi_write_png(outputPath.c_str(),
                       width,
                       height,
                       channels,
                       h_out,
                       width * channels);
    }
    else
    {
        stbi_write_jpg(outputPath.c_str(),
                       width,
                       height,
                       channels,
                       h_out,
                       100);
    }

    std::cout << "Saved: " << outputPath << "\n";

    // 🔹 Cleanup
    cudaFree(d_data);
    stbi_image_free(h_img);
    delete[] h_out;

    p.cleanup();

    return 0;
}