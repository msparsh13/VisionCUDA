#include<padding.hpp>
#include<kernels.hpp>
#include<string>
#include<stdexcept> 

KernelType parseKernel(const std::string& k) {
    if (k == "gaussian") return KernelType::GAUSSIAN;
    if (k == "box") return KernelType::BOX_BLUR;
    if (k == "sobel_x") return KernelType::SOBEL_X;
    if (k == "sobel_y") return KernelType::SOBEL_Y;

    throw std::runtime_error("Unknown kernel: " + k);
}

PaddingType parsePadding(const std::string& p) {
    if (p == "zero") return PaddingType::ZERO;
    if (p == "reflect") return PaddingType::REFLECT;
    if (p == "replicate") return PaddingType::REPLICATE;

    return PaddingType::ZERO;
}