# VisionCUDA

A learning-focused project exploring image processing techniques implemented from scratch in **C++ and CUDA**.  
The project features high-performance GPU-accelerated kernels orchestrated by a **JSON-driven pipeline system** for modular and flexible image processing workflows.

---

## 🚀 Overview

VisionCUDA allows you to define complex image processing pipelines through a simple JSON configuration. At runtime, the system parses the operations and maps them to optimized CUDA-backed implementations.

### Key Focus Areas
* **Kernel Development:** Hand-written CUDA kernels for fundamental image ops.
* **Memory Management:** Efficient handling of `cudaMalloc`, `cudaMemcpy`, and device-to-host transfers.
* **Modular Architecture:** A registry-based dispatcher allowing for easy extension of new operations.

---

## ⚙️ Build & Run

### Prerequisites
* **C++ Compiler:** MinGW-w64 (recommended) or GCC.
* **CUDA Toolkit:** Version 11.0+ recommended.
* **RapidJSON:** For configuration parsing.

### Installation
1. Clone the repository:
   git clone https://github.com/msparsh13/VisionCUDA.git
   cd VisionCUDA

2. Build the project:
   mingw32-make

### Execution
Run the compiled binary by passing the input path, output path, and your pipeline configuration:
./output/output.exe <input_img> <output_img> <pipeline.json>

---

## 📄 JSON Pipeline Format

The pipeline is defined as an array of operation objects. This allows for sequential processing without the need to recompile the source code.

[
  { "op": "grayscale" },
  { "op": "conv", "kernel": "gaussian", "ksize": 5 },
  { "op": "upsample", "scale": 2.0 },
  { "op": "dilate", "kernel_size": 3 }
]

---

## 🔧 Supported Operations

| Category       | Operations                                         | Parameters                           |
| :------------- | :------------------------------------------------- | :----------------------------------- |
| **Basic** | grayscale, binarize, threshold                     | threshold (int)                      |
| **Convolution**| conv                                               | kernel (gaussian/sobel), ksize       |
| **Intensity** | brightness, contrast_gain, gamma, log_transform    | brightness_offset, gamma (float)     |
| **Geometric** | affine, upsample, downsample                       | scale (float)                        |
| **Morphology** | dilate, erosion                                    | kernel_size                          |
| **Arithmetic** | add_img, sub_img                                   | -                                    |

---

## 🧠 Architecture

The system utilizes a **Registry Pattern** to decouple the JSON parsing logic from the CUDA execution kernels.

### Execution Flow
1. **Parser:** Reads pipeline.json using RapidJSON.
2. **Registry:** Maps the string "op" name to a specific OpHandler.
3. **Pipeline Builder:** Constructs a sequence of executable commands.
4. **CUDA Dispatcher:** Allocates device memory and launches asynchronous kernels.
5. **Output:** Transfers processed data back to the host and saves the final image.

### Project Structure
```bash
VisionCUDA/
├── src/
│   ├── ops/         # CUDA kernels & operation logic
│   ├── parser/      # JSON parser & registry
│   ├── pipeline/    # Execution logic
│   └── main.cpp
├── include/         # Headers
├── output/          # Build artifacts
├── Makefile
└── pipeline.json
```
---

## 🚧 Current Limitations & Roadmap

### Limitations
* **Linear Execution:** Currently supports sequential pipelines (No DAGs).
* **Sync Processing:** Does not yet utilize CUDA streams for concurrency.
* **Memory:** Lacks a dedicated memory pooling system for large batch operations.

### Future Improvements [no plan for now]
- [ ] **DAG Support:** Enable branching and merging pipelines.
- [ ] **Stream Parallelism:** Overlap data transfer with kernel execution.
- [ ] **Performance Benchmarking:** Automated CPU vs GPU latency reports.
- [ ] **Support different paddings**

---

## 👤 Author

**Sparsh Mahajan**
* **GitHub:** [@msparsh13](https://github.com/msparsh13)

---
