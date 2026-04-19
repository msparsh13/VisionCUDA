#pragma once
#include <unordered_map>
#include <functional>
#include <iostream>
#include <fstream>

#include <rapidjson/document.h>
#include <rapidjson/filereadstream.h>
#include<grayscaleOp.hpp>
#include<binarizeOp.hpp>
#include<affineOp.hpp>
#include<kernels.hpp>
#include<padding.hpp>
#include<convOp.hpp>
#include<pipeline.hpp>
#include<parserHelper.hpp>
#include<brightnessOp.hpp>
#include<gammaOp.hpp>
#include<negativeOp.hpp>
#include<logOp.hpp>
#include<openingOp.hpp>
#include<closingOp.hpp>
#include<SamplingOp.hpp>
#include<histogramEqlOp.hpp>
#include<matOp.hpp>
#include<dilationOp.hpp>
#include<erosionOp.hpp>

using namespace rapidjson;

class Pipeline;

// Handler signature
using OpHandler = std::function<void(const Value&, Pipeline&)>;

KernelType parseKernel(const std::string& k);
PaddingType parsePadding(const std::string& p);
void handleAffine(const Value& step, Pipeline& p);
void buildPipelineFromJSON(const std::string& filename, Pipeline& p);
GpuImage loadImageToGPU(const std::string& path);