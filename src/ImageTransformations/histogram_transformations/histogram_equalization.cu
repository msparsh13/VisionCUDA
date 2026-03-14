
__global__ void histogram_kernel(unsigned char* img, unsigned int* global_hist, int N);
__global__ void apply_lut(unsigned char* img, unsigned char* lut, int N);
__global__ void histogram_rgb_kernel(unsigned char* img, int width, int height, unsigned int* histR,
                                     unsigned int* histG, unsigned int* histB);
__global__ void apply_lut_rgb(unsigned char* img, unsigned char* lut, int N);

void histogram_wrap(unsigned char* img, unsigned int* hist, int N)
{
    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    histogram_kernel<<<blocks, threads>>>(img, hist, N);

    cudaDeviceSynchronize();

    unsigned int hist_cpu[256];

    cudaMemcpy(hist_cpu, hist, 256 * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    int cdf[256];
    cdf[0] = hist_cpu[0];

    int cdf_min = 0;
    for (int i = 1; i < 256; i++)
    {
        if (cdf_min == 0 && cdf[i - 1] != 0)
        {
            cdf_min = cdf[i - 1];
        }
        cdf[i] = cdf[i - 1] + hist_cpu[i];
    }

    unsigned char lut[256];

    for (int i = 0; i < 256; i++)
    {
        if (cdf[i] < cdf_min)
            lut[i] = 0;
        else
            lut[i] = (cdf[i] - cdf_min) * 255.0 / (N - cdf_min);
    }

    unsigned char* d_lut;
    cudaMalloc(&d_lut, 256);

    cudaMemcpy(d_lut, lut, 256, cudaMemcpyHostToDevice);

    apply_lut<<<blocks, threads>>>(img, d_lut, N);

    cudaDeviceSynchronize();

    cudaFree(d_lut);
}

__global__ void apply_lut_rgb(unsigned char* img, const unsigned char* lutR,
                              const unsigned char* lutG, const unsigned char* lutB, int N)
{
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N)
    {
        int pix = 3 * idx;
        img[pix + 0] = lutR[img[pix + 0]];  
        img[pix + 1] = lutG[img[pix + 1]]; 
        img[pix + 2] = lutB[img[pix + 2]];
    }
}

void histogram_wrap_rgb(unsigned char* img, int width, int height)
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
    auto compute_lut = [&](unsigned int* hist, unsigned char* lut)
    {
        int cdf[256];
        cdf[0] = hist[0];

        int cdf_min = 0;

        for (int i = 1; i < 256; i++)
        {
            cdf[i] = cdf[i - 1] + hist[i];

            if (cdf_min == 0 && hist[i] != 0) cdf_min = cdf[i];
        }

        for (int i = 0; i < 256; i++)
        {
            if (cdf[i] < cdf_min)
                lut[i] = 0;
            else
                lut[i] = (unsigned char)((float)(cdf[i] - cdf_min) / (float)(N - cdf_min) * 255.0f);
        }
    };

    unsigned char lutR[256], lutG[256], lutB[256];

    compute_lut(histR, lutR);
    compute_lut(histG, lutG);
    compute_lut(histB, lutB);

    unsigned char *d_img, *d_lutR, *d_lutG, *d_lutB;

    cudaMalloc(&d_img, 3 * N * sizeof(unsigned char));
    cudaMalloc(&d_lutR, 256 * sizeof(unsigned char));
    cudaMalloc(&d_lutG, 256 * sizeof(unsigned char));
    cudaMalloc(&d_lutB, 256 * sizeof(unsigned char));

    cudaMemcpy(d_img, img, 3 * N * sizeof(unsigned char), cudaMemcpyHostToDevice);

    cudaMemcpy(d_lutR, lutR, 256, cudaMemcpyHostToDevice);
    cudaMemcpy(d_lutG, lutG, 256, cudaMemcpyHostToDevice);
    cudaMemcpy(d_lutB, lutB, 256, cudaMemcpyHostToDevice);

    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    apply_lut_rgb<<<blocks, threads>>>(d_img, d_lutR, d_lutG, d_lutB, N);

    cudaDeviceSynchronize();

    cudaMemcpy(img, d_img, 3 * N * sizeof(unsigned char), cudaMemcpyDeviceToHost);

    cudaFree(d_img);
    cudaFree(d_lutR);
    cudaFree(d_lutG);
    cudaFree(d_lutB);
}