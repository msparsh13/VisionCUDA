#include<parserHelper.hpp>

std::unordered_map<std::string, OpHandler> buildRegistry() {
    std::unordered_map<std::string, OpHandler> reg;

    reg["grayscale"] = [](const Value& step, Pipeline& p) {
        p.add(new GrayscaleOp(GrayMode::SINGLE));
    };

    reg["binarize"] = [](const Value& step, Pipeline& p) {
        int t = step["threshold"].GetInt();
        p.add(new BinarizeOp(t));
    };

    reg["conv"] = [](const Value& step, Pipeline& p) {
        std::string kname = step["kernel"].GetString();
        KernelType ktype = parseKernel(kname);

        PaddingType pad = PaddingType::ZERO;
        if (step.HasMember("padding")) {
            pad = parsePadding(step["padding"].GetString());
        }

        int ksize = 3;
        if (step.HasMember("ksize")) {
            ksize = step["ksize"].GetInt();
        }

        p.add(new ConvolutionOp(ktype, pad));
    };

    reg["affine"] = [](const Value& step, Pipeline& p) {
        handleAffine(step, p);
    };

    reg["brightness"] = [](const Value& step, Pipeline& p){
        int alpha = step["contrast_gain"].GetInt();
        int beta = step["brightness_offset"].GetInt();
        p.add( new BrightnessOp(alpha , beta)) ;
    };

    reg["gamma"] = [](const Value& step, Pipeline& p){
        int gamma = step["gamma"].GetInt();
        
        p.add(new GammaOp(gamma)) ;
    };

     reg["log_transform"] = [](const Value& step, Pipeline& p){
        int val = step["value"].GetInt();
        
        p.add(new LogOp(val)) ;
    };

     reg["histogram_eql"] = [](const Value& step, Pipeline& p){
        p.add(new HistogramEqlOp()) ;
    };

    reg["add_img"]=[](const Value& step, Pipeline& p){
        GpuImage img = loadImageToGPU(step["image"].GetString());
        p.add(new AddOp(img));
  };

    reg["sub_img"]=[](const Value& step, Pipeline& p){
        GpuImage img = loadImageToGPU(step["image"].GetString());
        p.add(new SubtractOp(img));
  };
 
  reg["upsample"]=[](const Value& step, Pipeline& p){
        float scale = step["scale"].GetFloat();
        p.add(new SamplingOp(SamplingType::UPSAMPLE , scale));
  };

   reg["downsample"]=[](const Value& step, Pipeline& p){
        float scale = step["scale"].GetFloat();
        p.add(new SamplingOp(SamplingType::DOWNSAMPLE , scale));
  };

   reg["dilate"]=[](const Value& step, Pipeline& p){
        int kernel_size = step["kernel_size"].GetInt();
        p.add(new DilationOp( kernel_size));
  };

  reg["erosion"]=[](const Value& step, Pipeline& p){
        int kernel_size = step["kernel_size"].GetInt();
        p.add(new ErosionOp( kernel_size));
  };
    return reg;
}

void buildPipelineFromJSON(const std::string& filename, Pipeline& p) {
    FILE* fp = fopen(filename.c_str(), "r");
    if (!fp) {
        std::cout << "Failed to open JSON file\n";
        return;
    }

    char buffer[65536];
    FileReadStream is(fp, buffer, sizeof(buffer));

    Document doc;
    doc.ParseStream(is);
    fclose(fp);

    if (!doc.IsArray()) {
        std::cout << "JSON must be an array\n";
        return;
    }

    auto registry = buildRegistry();

    for (SizeType i = 0; i < doc.Size(); i++) {
        const Value& step = doc[i];

        if (!step.HasMember("op")) {
            std::cout << "Missing op field\n";
            continue;
        }

        std::string op = step["op"].GetString();

        if (registry.count(op)) {
            registry[op](step, p);
        } else {
            std::cout << "Unknown op: " << op << "\n";
        }
    }
}