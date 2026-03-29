#include <vector>
#include "kernels.hpp"

#include "padding.hpp"

__global__ void conv_vertical(unsigned char *input,
                              unsigned char *output, float *kernel, int width, int height, int channels);

__global__ void conv_horizontal(unsigned char *input,
                                unsigned char *output, float *kernel, int width, int height, int channels);

__global__ void downsample(
    unsigned char *input,
    unsigned char *output,
    int width, int height,
    int channels,
    int scale);

void pyramid_gaussian(
    unsigned char *h_input,
    std::vector<unsigned char *> &outputs,
    int width,
    int height,
    int kSize,
    int scale,
    int channels,
    int levels)
{
    unsigned char *d_input, *d_temp, *d_blur, *d_output;

    int curr_w = width;
    int curr_h = height;

    // copy input to GPU
    cudaMalloc(&d_input, curr_w * curr_h * channels * sizeof(unsigned char));
    cudaMemcpy(d_input, h_input, curr_w * curr_h * channels * sizeof(unsigned char), cudaMemcpyHostToDevice);

    auto kernelVecX = getKernel1D_X(KernelType::GAUSSIAN, kSize);
    auto kernelVecY = getKernel1D_Y(KernelType::GAUSSIAN, kSize);

    float *d_kernelX;
    float *d_kernelY;

    cudaMalloc(&d_kernelX, kSize * sizeof(float));
    cudaMalloc(&d_kernelY, kSize * sizeof(float));
    cudaMemcpy(d_kernelX, kernelVecX.data(), kSize * sizeof(float), cudaMemcpyHostToDevice);

    cudaMemcpy(d_kernelY, kernelVecY.data(), kSize * sizeof(float), cudaMemcpyHostToDevice);

    unsigned char *h_base = new unsigned char[curr_w * curr_h * channels];
    memcpy(h_base, h_input, curr_w * curr_h * channels);
    outputs.push_back(h_base);

    for (int i = 0; i < levels; i++)
    {
        // temp buffers
        cudaMalloc(&d_temp, curr_w * curr_h * channels * sizeof(unsigned char));
        cudaMalloc(&d_blur, curr_w * curr_h * channels * sizeof(unsigned char));

        dim3 block(16, 16);
        dim3 grid((curr_w + 15) / 16, (curr_h + 15) / 16);

        conv_horizontal<<<grid, block>>>(d_input, d_temp, d_kernelX, curr_w, curr_h, channels);

        conv_vertical<<<grid, block>>>(d_temp, d_blur, d_kernelY, curr_w, curr_h, channels);
        int new_w = curr_w / scale;
        int new_h = curr_h / scale;

        if (new_w == 0 || new_h == 0)
            break;

        cudaMalloc(&d_output, new_w * new_h * channels * sizeof(unsigned char));

        dim3 grid_ds((new_w + 15) / 16, (new_h + 15) / 16);

        downsample<<<grid_ds, block>>>(
            d_blur,
            d_output,
            curr_w,
            curr_h,
            channels,
            scale);

        cudaDeviceSynchronize();
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("CUDA ERROR: %s\n", cudaGetErrorString(err));
        }
        unsigned char *h_out = new unsigned char[new_w * new_h * channels];
        cudaMemcpy(h_out, d_output, new_w * new_h * channels * sizeof(unsigned char), cudaMemcpyDeviceToHost);

        outputs.push_back(h_out);

        cudaFree(d_temp);
        cudaFree(d_blur);
        cudaFree(d_input);
        d_input = nullptr;
        d_input = d_output;
        curr_w = new_w;
        curr_h = new_h;
    }
    cudaFree(d_kernelX);
    cudaFree(d_kernelY);
    cudaFree(d_input);
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        printf("CUDA ERROR: %s\n", cudaGetErrorString(err));
    }
}