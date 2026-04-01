#include <LogOp.hpp>
#include <log.h>

void LogOp::apply(unsigned char *&d_data,
                  unsigned char *d_temp,
                  int &width,
                  int &height,
                  int &channels)
{
    int size = width * height * channels;

    log_transform(d_data, size, scale);
}