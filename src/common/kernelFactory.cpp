#include <vector>

#include "kernels.hpp"

std::vector<float> getKernel2D(KernelType type, int& kSize)
{
    switch (type)
    {
        case KernelType::GAUSSIAN:
            kSize = 3;
            return {0.0625f, 0.125f, 0.0625f, 0.125f, 0.25f, 0.125f, 0.0625f, 0.125f, 0.0625f};

        case KernelType::BOX_BLUR:
            kSize = 3;
            return {0.111111f, 0.111111f, 0.111111f, 0.111111f, 0.111111f,
                    0.111111f, 0.111111f, 0.111111f, 0.111111f};

        case KernelType::SOBEL_X:
            kSize = 3;
            return {-1.0f, 0.0f, 1.0f, -2.0f, 0.0f, 2.0f, -1.0f, 0.0f, 1.0f};

        case KernelType::SOBEL_Y:
            kSize = 3;
            return {-1.0f, -2.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 2.0f, 1.0f};

        case KernelType::SHARPEN:
            kSize = 3;
            return {0.0f, -1.0f, 0.0f, -1.0f, 5.0f, -1.0f, 0.0f, -1.0f, 0.0f};
    }

    kSize = 0;
    return {};
}

std::vector<float> getKernel1D_X(KernelType type, int& kSize)
{
    switch (type)
    {
        case KernelType::GAUSSIAN:
            kSize = 3;
            return {0.25f, 0.5f, 0.25f};

        case KernelType::BOX_BLUR:
            kSize = 3;
            return {0.333333f, 0.333333f, 0.333333f};

        case KernelType::SOBEL_X:
            kSize = 3;
            return {-1.0f, 0.0f, 1.0f};

        case KernelType::SOBEL_Y:
            kSize = 3;
            return {1.0f, 2.0f, 1.0f};
    }

    kSize = 0;
    return {};
}

std::vector<float> getKernel1D_Y(KernelType type, int& kSize)
{
    switch (type)
    {
        case KernelType::GAUSSIAN:
            kSize = 3;
            return {0.25f, 0.5f, 0.25f};

        case KernelType::BOX_BLUR:
            kSize = 3;
            return {0.333333f, 0.333333f, 0.333333f};

        case KernelType::SOBEL_X:
            kSize = 3;
            return {1.0f, 2.0f, 1.0f};  // smoothing

        case KernelType::SOBEL_Y:
            kSize = 3;
            return {-1.0f, 0.0f, 1.0f};  // derivative
    }

    kSize = 0;
    return {};
}

bool isSeparable(KernelType type)
{
    switch (type)
    {
        case KernelType::GAUSSIAN:
        case KernelType::BOX_BLUR:
        case KernelType::SOBEL_X:
        case KernelType::SOBEL_Y:
            return true;

        case KernelType::SHARPEN:
            return false;
    }

    return false;
}