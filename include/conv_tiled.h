#pragma once

void conv_tiled(
    float* input,
    float* output,
    float* kernel,
    int width,
    int height,
    int kSize);