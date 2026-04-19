#include <cuda_runtime.h>
#include <stdexcept>
#include "stb_image.h"
#include<matOp.hpp>
#include<error_handling/cuda_err.hpp>

GpuImage loadImageToGPU(const std::string& path)
{
    int w, h, c;

    unsigned char* h_img = stbi_load(path.c_str(), &w, &h, &c, 0);
    if (!h_img) {
        throw std::runtime_error("Failed to load image: " + path);
    }

    size_t size =w * h * c * sizeof(unsigned char);

    unsigned char* d_img = nullptr;


try {
    CUDA_CHECK(cudaMalloc(&d_img, size));
    CUDA_CHECK(cudaMemcpy(d_img, h_img, size, cudaMemcpyHostToDevice));
}
catch (...) {
    stbi_image_free(h_img);
    if (d_img) cudaFree(d_img);
    throw;
}

stbi_image_free(h_img);

    return { d_img, w, h, c };
}