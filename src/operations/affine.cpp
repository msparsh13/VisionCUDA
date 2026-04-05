#include <vector>
#include "affine.h"
#include "affineOp.hpp"
#include "matrix.h"
#include <utility> 

void AffineOp::addTranslate(float tx, float ty)
{
    ops.push_back({TRANSLATE, tx, ty});
}

void AffineOp::addRotate(float theta)
{
    ops.push_back({ROTATE, theta, 0.0f});
}

void AffineOp::addShear(float shx, float shy)
{
    ops.push_back({SHEAR, shx, shy});
}

void AffineOp::apply(unsigned char *&d_data,
                     unsigned char *d_temp,
                     int &width,
                     int &height,
                     int &channels)
{

    affine_pipeline(d_data, d_temp,
                    width, height, channels,
                    ops);

    std::swap(d_data, d_temp);
}