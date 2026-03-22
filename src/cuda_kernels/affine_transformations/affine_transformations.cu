// inverse mapping from output to input so that no pxl is missed [holes]
#include <iostream>

__global__ void inverse_mapping(
    unsigned char *input,
    unsigned char *output,
    int width,
    int height,
    int channels,
    float a, float b, float c,
    float d, float e, float f)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;


    if (x >= width || y >= height)
        return;


    float src_x = a * x + b * y + c;
    float src_y = d * x + e * y + f;


    int x0 = floor(src_x);
    int y0 = floor(src_y);

    float dx = src_x - x0;
    float dy = src_y - y0;

     
    int out_idx = (y * width + x) * channels;


  if (x0 < 0 || x0 >= width - 1 || y0 < 0 || y0 >= height - 1)
    {
        for (int c = 0; c < channels; c++)
            output[out_idx + c] = 0;
        return;
    }

    /**
     * TODO implement multiple interpolations for such things i will use them later in pyramids id and upsampling
     */

    /**
     * Linear interpolation twice

        (x1,y1) ------- (x2,y1)
           |               |
           |     (x,y)     |
           |               |
        (x1,y2) ------- (x2,y2)

     * x1+1 = x2
     * y1+1 = y2
     * X axis
     *  f(x,y1​)=(1−dx​)f(x1​,y1​)+dx​f(x2​,y1​)
     *  f(x,y2​)=(1−dx​)f(x1​,y2​)+dx​f(x2​,y2​)
     *
     * Y axis
     * f(x,y)=(1−dy​)f(x,y1​)+dy​f(x,y2​)
     * now putting f(x,y1) and f(x,y2)
     * f(x,y)=(1−dx​)(1−dy​)f(x1​,y1​)+dx​(1−dy​)f(x2​,y1​)+(1−dx​)dy​f(x1​,y2​)+dx​dy​f(x2​,y2​)
     * wk y1 and x1
     * f(x,y)=(1−dx​)(1−dy​)f(x1​,y1​)+dx​(1−dy​)f(x1+1​,y1​)+(1−dx​)dy​f(x1​,y1+1​)+dx​dy​f(x1+1​,y1+1​)
     */


    int idx00 = (y0 * width + x0) * channels;
    int idx10 = (y0 * width + (x0 + 1))* channels;
    int idx01 = ((y0 + 1) * width + x0)* channels;
    int idx11 = ((y0 + 1) * width + (x0 + 1)) * channels;



   for (int c = 0; c < channels; c++)
{
    float p00 = (float)input[idx00 + c];
    float p10 = (float)input[idx10 + c];
    float p01 = (float)input[idx01 + c];
    float p11 = (float)input[idx11 + c];

    float val =
        (1 - dx) * (1 - dy) * p00 +
        dx * (1 - dy) * p10 +
        (1 - dx) * dy * p01 +
        dx * dy * p11;

    val = fminf(fmaxf(val, 0.0f), 255.0f);

    output[out_idx + c] = (unsigned char)(val);
}
}