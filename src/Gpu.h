#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#include "common.h"
#include "stddef.h"

#ifdef __cplusplus
extern "C" {
#endif

void GPU_DataCube_boxcar_filter(char *data, int word_size, size_t data_size, size_t *axis_size, size_t radius);

void GPU_DataCube_gauss_filter(char *data, int word_size, size_t data_size, size_t *axis_size, size_t radius, size_t n_iter);


__global__ void g_DataCube_boxcar_filter(float *data, float *data_box, int word_size, size_t width, size_t height, size_t depth, size_t radius);

__global__ void g_DataCube_gauss_filter_XDir(float *data, float *data_box, int word_size, size_t width, size_t height, size_t depth, size_t radius, size_t n_iter);

__global__ void g_DataCube_gauss_filter_YDir(float *data, float *data_box, int word_size, size_t width, size_t height, size_t depth, size_t radius, size_t n_iter);

__device__ void d_filter_boxcar_1d_flt(float *data, float *data_copy, const size_t size, const size_t filter_radius, const size_t jump);

__device__ void d_filter_boxcar_1d_flt_YDir(float *data, float *data_copy, const size_t size, const size_t filter_radius, const size_t size_y);

__device__ void d_filter_boxcar_1d_flt_ZDir(float *data, float *data_copy, const size_t size, const size_t filter_radius, const size_t size_z);

__device__ void d_filter_gauss_2d_flt(float *data, float *data_copy, float *data_row, float *data_col, const size_t size_x, const size_t size_y, const size_t n_iter, const size_t filter_radius);

__device__ inline size_t get_index( const size_t x, const size_t y, const size_t z, const size_t width, const size_t height)
{
	return x + width * (y + height * z);
}

#ifdef __cplusplus
}
#endif