#pragma once

void binary(unsigned char* d_img,
                      unsigned char* d_out,
                      int width,
                      int height ,
                    int thresh);

void binary_gray(unsigned char* d_img, unsigned char* d_out, int width, int height, int thresh);