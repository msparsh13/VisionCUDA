// Source - https://stackoverflow.com/a/1727896
// Posted by Ferenc Deak, modified by community. See post 'Timeline' for change history
// Retrieved 2026-03-22, License - CC BY-SA 3.0

#define M_PI 3.14159265358979323846 /* pi */
#include <vector>
#include <math.h>
#include "matrix.h"
#include "affine.h"

__global__ void inverse_mapping(
    unsigned char *input,
    unsigned char *output,
    int width,
    int height,
    int channels,
    float a, float b, float c,
    float d, float e, float f);

void create_identity(float mat[9])
{
    mat[0] = 1;
    mat[1] = 0;
    mat[2] = 0;
    mat[3] = 0;
    mat[4] = 1;
    mat[5] = 0;
    mat[6] = 0;
    mat[7] = 0;
    mat[8] = 1;
}

void convert_to_translate(float tx, float ty, float mat[9])
{
    create_identity(mat);
    mat[2] = tx;
    mat[5] = ty;
}

void convert_to_rotate(float theta, float mat[9])
{
    create_identity(mat);
    float rad = theta * M_PI / 180.0f;

    mat[0] = cos(rad);
    mat[1] = -sin(rad);
    mat[3] = sin(rad);
    mat[4] = cos(rad);
}

void convert_to_shear(float shx, float shy, float mat[9])
{
    create_identity(mat);
    mat[1] = shx;
    mat[3] = shy;
}

void affine_pipeline(unsigned char *img,
                     unsigned char *output,
                     int width,
                     int height,
                     int channels,
                     std::vector<TransformOpr> vec)
{
    float M[9];
    float temp[9];

    // identity
    create_identity(M);

    for (auto &op : vec)
    {
        if (op.type == TRANSLATE)
            convert_to_translate(op.v1, op.v2, temp);

        else if (op.type == ROTATE)
            convert_to_rotate(op.v1, temp);

        else if (op.type == SHEAR)
            convert_to_shear(op.v1, op.v2, temp);

        float result[9];
        multiply_cpu(temp, M, result);

        for (int i = 0; i < 9; i++)
            M[i] = result[i];
    }
    float M_inv[9];
    inverse3x3(M, M_inv);

    float a = M_inv[0], b = M_inv[1], c = M_inv[2];
    float d = M_inv[3], e = M_inv[4], f = M_inv[5];

    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);

    inverse_mapping<<<grid, block>>>(
        img, output,
        width, height, channels,
        a, b, c, d, e, f);
}

void affine_cuda(unsigned char *img,
                 unsigned char *output,
                 int width,
                 int height,
                 int channels,
                 std::vector<TransformOpr> vec)
{
    float M[9];
    float temp[9];

    create_identity(M);

    for (auto &op : vec)
    {
        if (op.type == TRANSLATE)
            convert_to_translate(op.v1, op.v2, temp);

        else if (op.type == ROTATE)
            convert_to_rotate(op.v1, temp);

        else if (op.type == SHEAR)
            convert_to_shear(op.v1, op.v2, temp);

        multiply_cpu(temp, M, M);
    }
    float M_inv[9];
    inverse3x3(M, M_inv);

    float a = M_inv[0], b = M_inv[1], c = M_inv[2];
    float d = M_inv[3], e = M_inv[4], f = M_inv[5];

    dim3 block(16, 16);
    dim3 grid((width + 15) / 16, (height + 15) / 16);

    inverse_mapping<<<grid, block>>>(
        img, output,
        width, height, channels,
        a, b, c, d, e, f);
}