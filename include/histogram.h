#pragma once

void launchHistogramRGB(unsigned char *d_img,
                        unsigned int *d_hist,
                        int width,
                        int height);
void launchApplyLUTGray(unsigned char *d_img,
                        unsigned char *d_lut,
                        int N);
void launchHistogramGray(unsigned char *d_img,
                         unsigned int *d_hist,
                         int N);
void launchApplyLUTRGB(unsigned char *d_img,
                       unsigned char *d_lutR,
                       unsigned char *d_lutG,
                       unsigned char *d_lutB,
                       int N);