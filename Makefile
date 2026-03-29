NVCC = nvcc
TARGET = output/output

NVCCFLAGS = -Iinclude
DEBUGFLAGS = -G -g

# Full project sources
SRC = src/main.cu \
      $(wildcard src/cuda_kernels/**/*.cu) \
      $(wildcard src/ImageTransformations/**/*.cu) \
      $(wildcard src/common/**/*.cpp) \
      $(wildcard src/mathsOperations/**/*.cu) \
      $(wildcard src/mathsOperations/**/*.cpp)

# Only matrix operations
MATRIX_SRC = src/main.cu \
      $(wildcard src/matrixOperations/**/*.cu) \
      $(wildcard src/matrixOperations/*.cpp)


all:
	$(NVCC) $(NVCCFLAGS) $(SRC) -o $(TARGET)

debug:
	$(NVCC) $(NVCCFLAGS) $(DEBUGFLAGS) $(SRC) -o $(TARGET)


matrix:
	$(NVCC) $(NVCCFLAGS) $(MATRIX_SRC) -o output/matrix_test

matrix_debug:
	$(NVCC) $(NVCCFLAGS) $(DEBUGFLAGS) $(MATRIX_SRC) -o output/matrix_test

clean:
	rm -f $(TARGET) output/matrix_test