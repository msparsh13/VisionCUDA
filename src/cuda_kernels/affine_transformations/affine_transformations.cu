//inverse mapping from output to input so that no pxl is missed [holes]

__global__ void affine_transform(
    unsigned char* input,
    unsigned char* output,
    int width,
    int height,
    float a, float b, float c,
    float d, float e, float f)
{
   int x = blockIdx.x + blockDim.x + threadIdx.x ;
   int y = blockIdx.y + blockDim.y + threadIdx.y ;

   if(x>=width || y>=height) return ;

   float src_x = a * x + b * y + c;
    float src_y = d * x + e * y + f;

    int x0 = floor(src_x) ;
    int y0 = floor(src_y) ;

    int dx = src_x - x0 ;
    int dy = src_y - y0;

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
    float val =
    (1-dx)*(1-dy)*input[y0 * width + x0] +   dx*(1-dy)*input[y0 * width + (x0+1)] +   

    (1-dx)*dy*input[(y0+1) * width + x0] +  dx*dy*input[(y0+1) * width + (x0+1)];
    
}