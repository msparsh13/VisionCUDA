#pragma once
#include <string>
#include "pipeline_err.hpp"

#define CUDA_CHECK(call) \
    do { \
        cudaError_t err = call; \
        if (err != cudaSuccess) { \
            throw PipelineException( \
                std::string("CUDA Error: ") + cudaGetErrorString(err) + \
                " at " + __FILE__ + ":" + std::to_string(__LINE__) \
            ); \
        } \
    } while (0)