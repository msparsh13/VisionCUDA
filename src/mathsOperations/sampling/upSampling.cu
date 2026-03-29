__global__ void upsample(unsigned char* input , unsigned char* output , int width , int height , int scale , int channels){
    int x_idx = blockDim.x*blockIdx.x+threadIdx.x;
    int y_idx = blockDim.y*blockIdx.y+threadIdx.y;

    int new_h = height*scale;
    int new_w = width*scale;

    if(x_idx>=new_w || y_idx >=new_h) return ;

    for (int c = 0; c < channels; c++)
    {
        int out_idx = (y_idx * new_w + x_idx) * channels + c;

        if (x_idx % scale == 0 && y_idx % scale == 0)
        {
            int in_x = x_idx / scale;
            int in_y = y_idx / scale;

            int in_idx = (in_y *width   + in_x) * channels + c;
            output[out_idx] = input[in_idx];
        }
        else
        {
            output[out_idx] = 0;
        }
    }
}