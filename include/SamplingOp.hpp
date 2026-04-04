#include<operations.hpp>

enum class SamplingType {
    DOWNSAMPLE,
    UPSAMPLE
};

class SamplingOp : public Operation
{
public:
    SamplingOp(SamplingType type , float scale) : type(type) , scale(scale) {}

    void apply(unsigned char*& d_data,
                unsigned char* d_temp,
               int& width,
               int& height,
               int& channels) override;

private:
    SamplingType type;
    float scale;
};