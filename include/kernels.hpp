#pragma once
#include <vector>

enum class KernelType
{
    GAUSSIAN,
    SOBEL_X,
    SOBEL_Y,
    SHARPEN,
    BOX_BLUR
};

std::vector<float> getKernel2D(KernelType type, int &kSize);
std::vector<float> getKernel1D_X(KernelType type, int &kSize);
std::vector<float> getKernel1D_Y(KernelType type, int &kSize);

bool isSeparable(KernelType type);