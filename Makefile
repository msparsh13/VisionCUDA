NVCC = nvcc
TARGET = output/output

NVCCFLAGS = -Iinclude

SRC = src/main.cu \
      $(wildcard src/cuda_kernels/**/*.cu) \
      $(wildcard src/ImageTransformations/**/*.cu) \
      $(wildcard src/common/**/*.cpp)

all:
	$(NVCC) $(NVCCFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)

