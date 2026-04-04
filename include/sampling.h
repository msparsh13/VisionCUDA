void downsample(unsigned char* d_in,
                      unsigned char* d_out,
                      int width,
                      int height,
                      int scale,
                      int channels);

void upsample(unsigned char* d_in,
                    unsigned char* d_out,
                    int width,
                    int height,
                    int scale,
                    int channels);