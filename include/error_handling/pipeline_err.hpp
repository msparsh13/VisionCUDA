#pragma once
#include <stdexcept>
#include <string>

class PipelineException : public std::runtime_error {
public:
    explicit PipelineException(const std::string& msg)
        : std::runtime_error(msg) {}
};