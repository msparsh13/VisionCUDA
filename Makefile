NVCC = nvcc
TARGET = ./output/output

SRC = src/main.cu \
      $(wildcard src/cuda_kernels/*.cu) \
      $(wildcard src/ImageTransformations/*.cu) \
	  $(wildcard src/common/*.cpp)

all:
	$(NVCC) $(SRC) -Iinclude -o $(TARGET)

clean:
	del $(TARGET).exe