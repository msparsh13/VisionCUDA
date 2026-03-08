#pragma once
#include <vector>

enum class KernelType
{
    GAUSSIAN,
    SOBEL_X,
    SOBEL_Y,
    SHARPEN,
    BOX
};


std::vector<float> getKernel(KernelType type, int& kSize);