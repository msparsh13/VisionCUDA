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