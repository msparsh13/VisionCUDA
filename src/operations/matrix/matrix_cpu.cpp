#include<math.h>
#include<iostream>

void inverse3x3(float M[9], float inv[9]) {
    float det =
        M[0]*(M[4]*M[8]-M[5]*M[7]) -
        M[1]*(M[3]*M[8]-M[5]*M[6]) +
        M[2]*(M[3]*M[7]-M[4]*M[6]);

    if (fabs(det) < 1e-8f) {
        printf("Non-invertible matrix!\n");
        return;
    }


    float invDet = 1.0f / det;

    inv[0] =  (M[4]*M[8]-M[5]*M[7]) * invDet;
    inv[1] = -(M[1]*M[8]-M[2]*M[7]) * invDet;
    inv[2] =  (M[1]*M[5]-M[2]*M[4]) * invDet;

    inv[3] = -(M[3]*M[8]-M[5]*M[6]) * invDet;
    inv[4] =  (M[0]*M[8]-M[2]*M[6]) * invDet;
    inv[5] = -(M[0]*M[5]-M[2]*M[3]) * invDet;

    inv[6] =  (M[3]*M[7]-M[4]*M[6]) * invDet;
    inv[7] = -(M[0]*M[7]-M[1]*M[6]) * invDet;
    inv[8] =  (M[0]*M[4]-M[1]*M[3]) * invDet;
}

void multiply_cpu(float A[9], float B[9], float C[9]) {
    float temp[9];

    for(int i=0;i<3;i++){
        for(int j=0;j<3;j++){
            temp[i*3+j] = 0;
            for(int k=0;k<3;k++){
                temp[i*3+j] += A[i*3+k] * B[k*3+j];
            }
        }
    }

    for(int i=0;i<9;i++) C[i] = temp[i];
}


