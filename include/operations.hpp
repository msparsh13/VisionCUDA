#pragma once

class Operation {
public:
    virtual void apply(unsigned char*& d_data,
                         unsigned char* d_temp,
                       int& width,
                       int& height,
                       int& channels) = 0;

    virtual ~Operation() {}
};