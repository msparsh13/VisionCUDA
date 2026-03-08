#include <vector>

enum class KernelType
{
    GAUSSIAN,
    SOBEL_X,
    SOBEL_Y,
    SHARPEN,
    BOX_BLUR
};

std::vector<float> getKernel(KernelType type, int &kSize)
{
    switch(type)
    {
        case KernelType::GAUSSIAN:
            kSize = 3;
            return {
                1,2,1,
                2,4,2,
                1,2,1
            };

        case KernelType::SOBEL_X:
            kSize = 3;
            return {
                -1,0,1,
                -2,0,2,
                -1,0,1
            };

        case KernelType::SOBEL_Y:
            kSize = 3;
            return {
                -1,-2,-1,
                 0, 0, 0,
                 1, 2, 1
            };

        case KernelType::SHARPEN:
            kSize = 3;
            return {
                 0,-1, 0,
                -1, 5,-1,
                 0,-1, 0
            };

        case KernelType::BOX_BLUR:
            kSize = 3;
            return {
                1,1,1,
                1,1,1,
                1,1,1
            };
    }

    kSize = 0;
    return {};
}