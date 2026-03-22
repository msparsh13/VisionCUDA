void dilation(unsigned char* d_img,
              unsigned char* d_out,
              int width,
              int height,
              int kSize);

void erosion(unsigned char* d_img,
              unsigned char* d_out,
              int width,
              int height,
              int kSize);

void opening(unsigned char* d_input,
             unsigned char* d_output,
             int width, int height,
             int kSize);