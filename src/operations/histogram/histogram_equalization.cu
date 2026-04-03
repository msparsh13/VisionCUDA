#include<histogram.h>
#include<histogramEqlOp.hpp>

void HistogramEqlOp::apply(unsigned char*& d_data,
    unsigned char* d_temp,
                                    int& width,
                                    int& height,
                                    int& channels)
{
    int N = width * height;

    if (channels == 1)
    {
  
        equalizeGray(d_data, N);
    }
    else if (channels == 3)
    {

        equalizeRGB(d_data, width, height);
    }
}
void HistogramEqlOp::equalizeGray(unsigned char*& d_data, int N)
{
    unsigned int* d_hist;
    cudaMalloc(&d_hist, 256 * sizeof(unsigned int));
    cudaMemset(d_hist, 0, 256 * sizeof(unsigned int));

    launchHistogramGray(d_data, d_hist, N);

    unsigned int hist[256];
    cudaMemcpy(hist, d_hist, 256 * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    unsigned char lut[256];
    computeLUT(hist, lut, N);

    unsigned char* d_lut;
    cudaMalloc(&d_lut, 256);
    cudaMemcpy(d_lut, lut, 256, cudaMemcpyHostToDevice);

    launchApplyLUTGray(d_data, d_lut, N);

    cudaFree(d_hist);
    cudaFree(d_lut);
}

void HistogramEqlOp::equalizeRGB(unsigned char*& d_data,
                                          int width,
                                          int height)
{
    int N = width * height;

    unsigned int* d_hist;
    cudaMalloc(&d_hist, 3 * 256 * sizeof(unsigned int));
    cudaMemset(d_hist, 0, 3 * 256 * sizeof(unsigned int));

    launchHistogramRGB(d_data, d_hist, width, height);

    unsigned int hist[3 * 256];
    cudaMemcpy(hist, d_hist, 3 * 256 * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    unsigned char lutR[256], lutG[256], lutB[256];

    computeLUT(&hist[0], lutR, N);
    computeLUT(&hist[256], lutG, N);
    computeLUT(&hist[512], lutB, N);

    unsigned char *d_lutR, *d_lutG, *d_lutB;

    cudaMalloc(&d_lutR, 256);
    cudaMalloc(&d_lutG, 256);
    cudaMalloc(&d_lutB, 256);

    cudaMemcpy(d_lutR, lutR, 256, cudaMemcpyHostToDevice);
    cudaMemcpy(d_lutG, lutG, 256, cudaMemcpyHostToDevice);
    cudaMemcpy(d_lutB, lutB, 256, cudaMemcpyHostToDevice);


    launchApplyLUTRGB(d_data, d_lutR, d_lutG, d_lutB, N);

    cudaFree(d_hist);
    cudaFree(d_lutR);
    cudaFree(d_lutG);
    cudaFree(d_lutB);
}

void HistogramEqlOp::computeLUT(unsigned int* hist,
                                         unsigned char* lut,
                                         int N)
{
    int cdf[256];

    // Step 1: Compute CDF
    cdf[0] = hist[0];
    for (int i = 1; i < 256; i++)
    {
        cdf[i] = cdf[i - 1] + hist[i];
    }

    int cdf_min = 0;
    for (int i = 0; i < 256; i++)
    {
        if (cdf[i] != 0)
        {
            cdf_min = cdf[i];
            break;
        }
    }

    if (cdf_min == N)
    {
        for (int i = 0; i < 256; i++)
            lut[i] = 0;
        return;
    }

    float scale = 255.0f / (float)(N - cdf_min);

    for (int i = 0; i < 256; i++)
    {
        if (cdf[i] < cdf_min)
        {
            lut[i] = 0;
        }
        else
        {
            lut[i] = (unsigned char)((cdf[i] - cdf_min) * scale);
        }
    }
}