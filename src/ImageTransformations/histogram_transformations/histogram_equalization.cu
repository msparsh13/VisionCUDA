
__global__ void histogram_gray_kernel(unsigned char *img,
                                      unsigned int *global_hist,
                                      int N);
__global__ void apply_lut_gray(unsigned char *img,
                               unsigned char *lut,
                               int N);

__global__ void histogram_rgb_kernel(unsigned char *img,
                                     int N,
                                     unsigned int *global_hist);
__global__ void apply_lut_rgb(unsigned char *img,
                              unsigned char *lutR,
                              unsigned char *lutG,
                              unsigned char *lutB,
                              int N);

void launchHistogramGray(unsigned char *d_img,
                         unsigned int *d_hist,
                         int N)
{
    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    histogram_gray_kernel<<<blocks, threads>>>(d_img, d_hist, N);
    cudaDeviceSynchronize();
}

void launchHistogramRGB(unsigned char *d_img,
                        unsigned int *d_hist,
                        int width,
                        int height)
{
    int N = width * height;

    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    histogram_rgb_kernel<<<blocks, threads>>>(d_img, N, d_hist);
    cudaDeviceSynchronize();
}

void launchApplyLUTGray(unsigned char *d_img,
                        unsigned char *d_lut,
                        int N)
{
    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    apply_lut_gray<<<blocks, threads>>>(d_img, d_lut, N);
    cudaDeviceSynchronize();
}

void launchApplyLUTRGB(unsigned char *d_img,
                       unsigned char *d_lutR,
                       unsigned char *d_lutG,
                       unsigned char *d_lutB,
                       int N)
{
    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    apply_lut_rgb<<<blocks, threads>>>(d_img, d_lutR, d_lutG, d_lutB, N);
    cudaDeviceSynchronize();
}
