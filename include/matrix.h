void multiply_cpu(float A[9], float B[9], float C[9]);
void inverse3x3(float M[9], float inv[9]) ;
void add(unsigned char* A,
               unsigned char* B,
               unsigned char* out,
               int width,
               int height,
               int channels);

void subtract(unsigned char* A,
                    unsigned char* B,
                    unsigned char* out,
                    int width,
                    int height,
                    int channels);

void scale(unsigned char* img,
                 int width,
                 int height,
                 int channels,
                 int factor);

void mul(float* d_A,
                  float* d_B,
                  float* d_C,
                  int M, int K, int N) ;