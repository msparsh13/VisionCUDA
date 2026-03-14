/**
 * IGNORE THE MAIN CURRENTLY ITS JUST A PLAY GROUND
 */

#include <iostream>
#define STB_IMAGE_IMPLEMENTATION
#include "../include/stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../include/stb_image_write.h"

#include "../include/convolution.h"
#include "./common/kernelFactory.cpp"
#include <cuda_runtime.h>

#include "../include/histogram.h"

#include <iostream>

void print_histogram_rgb(unsigned char *img, int width, int height)
{
    int N = width * height;

    unsigned int histR[256] = {0};
    unsigned int histG[256] = {0};
    unsigned int histB[256] = {0};

    for (int i = 0; i < N; i++)
    {
        histR[img[3 * i + 0]]++;
        histG[img[3 * i + 1]]++;
        histB[img[3 * i + 2]]++;
    }

    std::cout << "Red Channel Histogram:\n";
    for (int i = 0; i < 256; i++)
        std::cout << i << ":" << histR[i] << " ";
    std::cout << "\n\n";

    std::cout << "Green Channel Histogram:\n";
    for (int i = 0; i < 256; i++)
        std::cout << i << ":" << histG[i] << " ";
    std::cout << "\n\n";

    std::cout << "Blue Channel Histogram:\n";
    for (int i = 0; i < 256; i++)
        std::cout << i << ":" << histB[i] << " ";
    std::cout << "\n\n";
}

int main(int argc, char **argv)
{
    if (argc < 2)
    {
        std::cout << "Usage: " << argv[0] << " input.png\n";
        return 0;
    }

    const char *inputFile = argv[1];

    int width, height, channels;

    unsigned char *img = stbi_load(inputFile, &width, &height, &channels, 3);
    if (!img)
    {
        std::cerr << "Failed to load image: " << inputFile << "\n";
        return -1;
    }

    std::cout << "Image Loaded: " << width << " x " << height
              << " Channels: " << 3 << "\n";

    histogram_wrap_rgb(img, width, height);

    const char *outputFile = "./output/hist_equalized.png";
    if (!stbi_write_png(outputFile, width, height, 3, img, width * 3))
    {
        std::cerr << "Failed to save image: " << outputFile << "\n";
    }
    else
    {
        std::cout << "Saved histogram-equalized image: " << outputFile << "\n";
    }

    stbi_image_free(img);

    return 0;
}