#include<operations.hpp>

class HistogramEqlOp : public Operation {
 void equalizeGray(unsigned char*& d_data, int N);


    void equalizeRGB(unsigned char*& d_data, int width, int height);

    void computeLUT(unsigned int* hist, unsigned char* lut, int N);
public:
    HistogramEqlOp(){}

    void apply(unsigned char*& d_data,
         unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override; 
};