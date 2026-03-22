#pragma once 
enum TransformType {
    TRANSLATE,
    ROTATE,
    SHEAR
};

struct TransformOp {
    TransformType type;
    float v1, v2;
};

void affine_pipeline(unsigned char* img,
                     unsigned char* output,
                     int width,
                     int height,
                     int channels,
                     std::vector<TransformOp> vec);

               
