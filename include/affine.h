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

void convert_to_translate(float tx, float ty, float mat[9]);

void convert_to_rotate(float theta, float mat[9]) ;


void convert_to_shear(float shx, float shy, float mat[9]) ;

