#include<affineOp.hpp>
#include<string>
#include<pipeline.hpp>
#include<parserHelper.hpp>

void handleAffine(const Value& step, Pipeline& p) {
    if (!step.HasMember("transforms") || !step["transforms"].IsArray()) {
// add something here
        return;
    }

    const auto& arr = step["transforms"];
    AffineOp* aff = new AffineOp();

    for (SizeType i = 0; i < arr.Size(); i++) {
        const Value& t = arr[i];

        if (!t.HasMember("type")) continue;
        std::string type = t["type"].GetString();

        if (type == "rotate" && t.HasMember("angle")) {
            aff->addRotate(t["angle"].GetFloat());
        }
        else if (type == "translate") {
            aff->addTranslate(t["tx"].GetFloat(), t["ty"].GetFloat());
        }
        else if (type == "shear") {
            aff->addShear(t["shx"].GetFloat(), t["shy"].GetFloat());
        }
    }

    p.add(aff);
}