#include "Gpu.h"

void GPU_DataCube_filter(char *data, char *originalData, int word_size, size_t data_size, size_t *axis_size, size_t radiusGauss, size_t n_iter, size_t radiusBoxcar)
{
    // TODO let chunk ammount be calculated instead of hard coded
    GPU_DataCube_filter_Chunked(data, originalData, word_size, data_size, axis_size, radiusGauss, n_iter, radiusBoxcar, 15);
}

void GPU_DataCube_filter_Chunked(char *data, char *originalData, int word_size, size_t data_size, size_t *axis_size, size_t radiusGauss, size_t n_iter, size_t radiusBoxcar, size_t number_of_chunks)
{
    size_t number_of_chunks;
    char* data_copy;
    float* first_data;
    float* second_data;

<<<<<<< HEAD
    data_copy = (char*) malloc(axis_size[0] * axis_size[1] * axis_size[2] * word_size * sizeof(char));
    first_data = (float*) malloc(axis_size[0] * axis_size[1] * axis_size[2] * sizeof(float));
    second_data = (float*) malloc(axis_size[0] * axis_size[1] * axis_size[2] * sizeof(float));

    for(int i = 0; i < axis_size[0] * axis_size[1] * axis_size[2] * word_size; i++) data_copy[i] = data[i];

    for (int t = 0; t <= 1; t++)
=======
    // Error at start?
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624
    {
        if (t == 0) number_of_chunks = 1;
        else number_of_chunks = 100;

        for(int i = 0; i < axis_size[0] * axis_size[1] * axis_size[2] * word_size; i++) data[i] = data_copy[i];

        if (!radiusGauss && ! radiusBoxcar) {return;}

        printf("N-Iter: %lu\n", n_iter);

<<<<<<< HEAD
        // Error at start?
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error at start: %s\n", cudaGetErrorString(err));    
        }

        // check for CUDA capable device
        cudaFree(0);
        int deviceCount;
        cudaDeviceProp prop;
        cudaGetDeviceCount(&deviceCount);
        if (deviceCount == 0) {
            printf("No CUDA devices found.\n");
            exit(0);
        }

        cudaGetDeviceProperties(&prop, 0);
=======
    size_t x_overlap = axis_size[1] * axis_size[2] * 2 * radiusGauss;
    size_t y_overlap = axis_size[0] * axis_size[2] * 2 * radiusGauss;
    size_t z_overlap = axis_size[0] * axis_size[1] * 2 * radiusBoxcar;

    size_t box_size =   (data_size 
                            + (x_overlap > y_overlap ? (x_overlap > z_overlap ? x_overlap : z_overlap) 
                            : (y_overlap > z_overlap ? y_overlap : z_overlap))
                        ) 
                        * sizeof(float);
    size_t slices_per_chunk = axis_size[2] / number_of_chunks;
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624

        // Allocate and copy Datacube data onto GPU
        float *d_data;
        float *d_data_box;

<<<<<<< HEAD
        err = cudaGetLastError();
=======
    // if (prop.totalGlobalMem < 2 * box_size)
    // {
    //     number_of_chunks = ((2 * box_size) / prop.totalGlobalMem) + 1;
    //     slices_per_chunk /= number_of_chunks;
    //     slices_per_chunk++;
    // }

    // if (slices_per_chunk < 2 * radiusBoxcar + 1)
    // {
    //     printf("Insufficient memory on GPU to load enought slices of the cube to perform the boxcar filter.\n");
    //     exit(1);
    // }

    size_t chunk_overlap = x_overlap > y_overlap ? 
                        (x_overlap > z_overlap ? x_overlap : z_overlap) : 
                        (y_overlap > z_overlap ? y_overlap : z_overlap);

    err = cudaMalloc((void**)&d_data, (slices_per_chunk + 2 * radiusBoxcar) * axis_size[0] * axis_size[1] * word_size * sizeof(char));
    if (err != cudaSuccess)
    {
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624
        printf("%s\n", cudaGetErrorString(err));

        size_t x_overlap = axis_size[1] * axis_size[2] * 2 * radiusGauss;
        size_t y_overlap = axis_size[0] * axis_size[2] * 2 * radiusGauss;
        size_t z_overlap = axis_size[0] * axis_size[1] * 2 * radiusBoxcar;

        size_t box_size =   (data_size 
                                + (x_overlap > y_overlap ? (x_overlap > z_overlap ? x_overlap : z_overlap) 
                                : (y_overlap > z_overlap ? y_overlap : z_overlap))
                            ) 
                            * sizeof(float);
        size_t slices_per_chunk = axis_size[2] / number_of_chunks;

<<<<<<< HEAD
        x_overlap = slices_per_chunk * axis_size[1] * 2 * radiusGauss;
        y_overlap = slices_per_chunk * axis_size[0] * 2 * radiusGauss;
=======
    size_t remaining_slices = axis_size[2];
    int processed_chunks = 0;

    if (number_of_chunks > 1)
    {
        // TODO protect against thin cubes, where the first copy with a large boxcar filter may not succeed
        cudaMemcpy(d_data + radiusBoxcar * axis_size[0] * axis_size[1], data, (slices_per_chunk + radiusBoxcar) * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyHostToDevice);
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624

        // if (prop.totalGlobalMem < 2 * box_size)
        // {
        //     number_of_chunks = ((2 * box_size) / prop.totalGlobalMem) + 1;
        //     slices_per_chunk /= number_of_chunks;
        //     slices_per_chunk++;
        // }

        // if (slices_per_chunk < 2 * radiusBoxcar + 1)
        // {
        //     printf("Insufficient memory on GPU to load enought slices of the cube to perform the boxcar filter.\n");
        //     exit(1);
        // }

        size_t chunk_overlap = x_overlap > y_overlap ? 
                            (x_overlap > z_overlap ? x_overlap : z_overlap) : 
                            (y_overlap > z_overlap ? y_overlap : z_overlap);

        err = cudaMalloc((void**)&d_data, (slices_per_chunk + 2 * radiusBoxcar) * axis_size[0] * axis_size[1] * word_size * sizeof(char));
        if (err != cudaSuccess)
        {
            printf("%s\n", cudaGetErrorString(err));
            exit(0);
        }

<<<<<<< HEAD
        err = cudaMemset(d_data, 0, (slices_per_chunk + 2 * radiusBoxcar) * axis_size[0] * axis_size[1] * word_size * sizeof(char));
=======
        // Boxcar Filter in Z Direction
        dim3 blockSizeZ(32,32);
        dim3 gridSizeZ((axis_size[0] + blockSizeZ.x - 1) / blockSizeZ.x,
                    (axis_size[1] + blockSizeZ.y - 1) / blockSizeZ.y);

        if (radiusBoxcar) g_DataCube_boxcar_filter<<<gridSizeZ, blockSizeZ>>>(d_data, originalData, d_data_box, word_size, processed_chunks * slices_per_chunk, axis_size[0], axis_size[1], slices_per_chunk, radiusBoxcar, 0);

        cudaDeviceSynchronize();

        // Error before Kernel Launch?
        err = cudaGetLastError();
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624
        if (err != cudaSuccess)
        {
            printf("%s\n", cudaGetErrorString(err));
            exit(0);
        }

        err = cudaMalloc((void**)&d_data_box, (slices_per_chunk * axis_size[0] * axis_size[1] + chunk_overlap) * sizeof(float));
        if (err != cudaSuccess)
        {
            printf("%s\n", cudaGetErrorString(err));
            exit(0);
        }

        size_t remaining_slices = axis_size[2];
        int processed_chunks = 0;

        if (number_of_chunks > 1)
        {
            // TODO protect against thin cubes, where the first copy with a large boxcar filter may not succeed
            cudaMemcpy(d_data + radiusBoxcar * axis_size[0] * axis_size[1], data, (slices_per_chunk + radiusBoxcar) * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyHostToDevice);

<<<<<<< HEAD
            // Error after mem copy?
            err = cudaGetLastError();
=======
        if (radiusGauss) g_DataCube_gauss_filter_YDir<<<gridSizeY, blockSizeY>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

        cudaDeviceSynchronize();

        // Error after Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after Ykernel launch: %s\n", cudaGetErrorString(err));    
        }

        cudaMemcpy(data, d_data + radiusBoxcar * axis_size[0] * axis_size[1], slices_per_chunk * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyDeviceToHost);
        // Error after backkcopy??
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after backcopy: %s\n", cudaGetErrorString(err));
        }

        remaining_slices -= slices_per_chunk;
        processed_chunks++;
    }

    while(remaining_slices > slices_per_chunk)
    {
        //size_t remaining_slices = axis_size[2] - i * slices_per_chunk;
        size_t slices_to_copy = min(slices_per_chunk + radiusBoxcar, remaining_slices);

        cudaMemcpy(d_data + radiusBoxcar * axis_size[0] * axis_size[1], data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, slices_to_copy *  axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyHostToDevice);

        // If there are not enought slices left at the end fill the overlap region with zeroes where neccessary
        if (slices_to_copy < (slices_per_chunk + radiusBoxcar))
        {
            float *zeroes = (float*)calloc((slices_per_chunk + radiusBoxcar - slices_to_copy) * axis_size[0] * axis_size[1], sizeof(float));
            //err = cudaMemcpy(d_data + (radiusBoxcar + slices_to_copy) * axis_size[0] * axis_size[1], zeroes, (slices_per_chunk + radiusBoxcar - slices_to_copy) * axis_size[0] * axis_size[1] * sizeof(float), cudaMemcpyHostToDevice);
            err = cudaMemset(d_data + (radiusBoxcar + slices_to_copy) * axis_size[0] * axis_size[1], 0, (slices_per_chunk + radiusBoxcar - slices_to_copy) * axis_size[0] * axis_size[1] * word_size);
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624
            if (err != cudaSuccess)
            {
                printf("Cuda error at mem Copy to device: %s\n", cudaGetErrorString(err));    
            }

            // Boxcar Filter in Z Direction
            dim3 blockSizeZ(32,32);
            dim3 gridSizeZ((axis_size[0] + blockSizeZ.x - 1) / blockSizeZ.x,
                        (axis_size[1] + blockSizeZ.y - 1) / blockSizeZ.y);

            if (radiusBoxcar) g_DataCube_boxcar_filter<<<gridSizeZ, blockSizeZ>>>(d_data, d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusBoxcar, 0);

            cudaDeviceSynchronize();
<<<<<<< HEAD

            // Error before Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error before Xkernel launch: %s\n", cudaGetErrorString(err));    
            }

            // Gauss Filter size in X Direction
            dim3 blockSizeX(ceil((float)32 / number_of_chunks),32);
            dim3 gridSizeX((slices_per_chunk + blockSizeX.x - 1) / blockSizeX.x ,
                        (axis_size[1] + blockSizeX.y - 1) / blockSizeX.y);

            if (radiusGauss) g_DataCube_gauss_filter_XDir<<<gridSizeX, blockSizeX, axis_size[0] * sizeof(float) + (axis_size[0] + 2 * radiusGauss) * sizeof(float)>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

            cudaDeviceSynchronize();

            // Error after Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after Xkernel launch: %s\n", cudaGetErrorString(err));    
            }

            // Gauss Filter in Y Direction
            dim3 blockSizeY(ceil((float)16 / number_of_chunks),16);
            dim3 gridSizeY((slices_per_chunk + blockSizeY.x - 1) / blockSizeY.x,
                        (axis_size[0] + blockSizeY.y - 1) / blockSizeY.y);

            // Error before Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error before Ykernel launch: %s\n", cudaGetErrorString(err));    
            }

            if (radiusGauss) g_DataCube_gauss_filter_YDir<<<gridSizeY, blockSizeY>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

            cudaDeviceSynchronize();

            // Error after Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after Ykernel launch: %s\n", cudaGetErrorString(err));    
            }

            cudaMemcpy(data, d_data + radiusBoxcar * axis_size[0] * axis_size[1], slices_per_chunk * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyDeviceToHost);
            // Error after backkcopy??
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after backcopy: %s\n", cudaGetErrorString(err));
            }

            remaining_slices -= slices_per_chunk;
            processed_chunks++;
=======
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624
        }

        while(remaining_slices > slices_per_chunk)
        {
            //size_t remaining_slices = axis_size[2] - i * slices_per_chunk;
            size_t slices_to_copy = min(slices_per_chunk + radiusBoxcar, remaining_slices);

            cudaMemcpy(d_data + radiusBoxcar * axis_size[0] * axis_size[1], data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, slices_to_copy *  axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyHostToDevice);

            if (processed_chunks * slices_per_chunk < radiusBoxcar)
            {
                printf("Not enought slices processed yet. Filling beginning with zeroes\n");
                cudaMemset(d_data, 0, (radiusBoxcar - processed_chunks * slices_per_chunk) * axis_size[0] * axis_size[1] * sizeof(float));
                cudaDeviceSynchronize();
            }

            if (slices_to_copy < (slices_per_chunk + radiusBoxcar))
            {
                printf("Not enought slices remaining needed %lu slices but only had %lu left. filling rest with zeroes\n", slices_per_chunk + radiusBoxcar, slices_to_copy);
                float *zeroes = (float*)calloc((slices_per_chunk + radiusBoxcar - slices_to_copy) * axis_size[0] * axis_size[1], sizeof(float));
                //err = cudaMemcpy(d_data + (radiusBoxcar + slices_to_copy) * axis_size[0] * axis_size[1], zeroes, (slices_per_chunk + radiusBoxcar - slices_to_copy) * axis_size[0] * axis_size[1] * sizeof(float), cudaMemcpyHostToDevice);
                err = cudaMemset(d_data + (radiusBoxcar + slices_to_copy) * axis_size[0] * axis_size[1], 0, (slices_per_chunk + radiusBoxcar - slices_to_copy) * axis_size[0] * axis_size[1] * word_size);
                if (err != cudaSuccess)
                {
                    printf("Cuda error at memSet on device: %s\n", cudaGetErrorString(err));
                }
                cudaDeviceSynchronize();

                float *test_data = (float*)malloc((slices_per_chunk + 2 * radiusBoxcar) * axis_size[0] * axis_size[1] * word_size);
                cudaMemcpy(test_data, d_data, (slices_per_chunk + 2 * radiusBoxcar) * axis_size[0] * axis_size[1] * word_size, cudaMemcpyDeviceToHost);

                for (int j = 0; j < slices_per_chunk + 2 * radiusBoxcar; j++) printf("first value in slice %i is %f\n", j, test_data[j * axis_size[0] * axis_size[1]]);
                free(test_data);
            }
            
            // Error after mem copy?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error at mem Copy to device: %s\n", cudaGetErrorString(err));    
            }

            // Boxcar Filter in Z Direction
            dim3 blockSizeZ(32,32);
            dim3 gridSizeZ((axis_size[0] + blockSizeZ.x - 1) / blockSizeZ.x,
                        (axis_size[1] + blockSizeZ.y - 1) / blockSizeZ.y);

            if (radiusBoxcar) g_DataCube_boxcar_filter<<<gridSizeZ, blockSizeZ>>>(d_data, d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusBoxcar, 1);

            cudaDeviceSynchronize();
            
            // Error before Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error before Xkernel launch: %s\n", cudaGetErrorString(err));    
            }

            // Gauss Filter size in X Direction
            dim3 blockSizeX(ceil((float)32 / number_of_chunks),32);
            dim3 gridSizeX((slices_per_chunk + blockSizeX.x - 1) / blockSizeX.x ,
                        (axis_size[1] + blockSizeX.y - 1) / blockSizeX.y);

            if (radiusGauss) g_DataCube_gauss_filter_XDir<<<gridSizeX, blockSizeX, axis_size[0] * sizeof(float) + (axis_size[0] + 2 * radiusGauss) * sizeof(float)>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

            cudaDeviceSynchronize();

            // Error after Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after Xkernel launch: %s\n", cudaGetErrorString(err));    
            }

            // Gauss Filter in Y Direction
            dim3 blockSizeY(ceil((float)16 / number_of_chunks),16);
            dim3 gridSizeY((slices_per_chunk + blockSizeY.x - 1) / blockSizeY.x,
                        (axis_size[0] + blockSizeY.y - 1) / blockSizeY.y);

            // Error before Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error before Ykernel launch: %s\n", cudaGetErrorString(err));    
            }

            if (radiusGauss) g_DataCube_gauss_filter_YDir<<<gridSizeY, blockSizeY>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

            cudaDeviceSynchronize();

            // Error after Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after Ykernel launch: %s\n", cudaGetErrorString(err));    
            }

            cudaMemcpy(data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, d_data + radiusBoxcar * axis_size[0] * axis_size[1], slices_per_chunk * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyDeviceToHost);
            // Error after backkcopy??
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after backcopy: %s\n", cudaGetErrorString(err));
            }

            remaining_slices -= slices_per_chunk;

            printf("Finished chunk %i\n", processed_chunks + 1);

            processed_chunks++;
        }

        // err = cudaMalloc((void**)&d_data, data_size * word_size * sizeof(char));
        // if (err != cudaSuccess)
        // {
        //     printf("%s\n", cudaGetErrorString(err));
        //     exit(0);
        // }


        // err = cudaMalloc((void**)&d_data_box, (data_size + 
        //                                         (x_overlap > y_overlap ? (x_overlap > z_overlap ? x_overlap : z_overlap) 
        //                                         : (y_overlap > z_overlap ? y_overlap : z_overlap))) 
        //                                         * sizeof(float));
        // if (err != cudaSuccess)
        // {
        //     printf("%s\n", cudaGetErrorString(err));
        //     exit(0);
        // }

        // for (int i = 0; i < blockSizeX.x; i++)
        // {
        //     for (int j = 0; j < blockSizeX.y; j++)
        //     {
        //         cudaMemcpy(d_data 
        //                         + min(i * axis_size[0] * axis_size[1] * gridSizeX.x + (gridSizeX.x - 1) * axis_size[0] * axis_size[1], (axis_size[2]- 1) * axis_size[0] * axis_size[1])
        //                         + min(j * axis_size[0] * gridSizeX.y + (gridSizeX.y - 1) * axis_size[0], (axis_size[1] - 1) * axis_size[0])
        //                         + axis_size[0] - 1, 
        //                         &flag, sizeof(char), cudaMemcpyHostToDevice);
        //     }
        // }

        printf("Got to last chunk\n");

        size_t last_chunk_size = remaining_slices;

        if (last_chunk_size > 0)
        {
            printf("Now processing last chunk with %lu slices remaining\n", last_chunk_size);

            cudaMemcpy(d_data + radiusBoxcar * axis_size[0] * axis_size[1], data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, last_chunk_size * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyHostToDevice);
            // Error after mem copy?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error at last mem Copy to device: %s\n", cudaGetErrorString(err));    
            }

            // Boxcar Filter in Z Direction
            dim3 blockSizeZ(32,32);
            dim3 gridSizeZ((axis_size[0] + blockSizeZ.x - 1) / blockSizeZ.x,
                        (axis_size[1] + blockSizeZ.y - 1) / blockSizeZ.y);

            if (radiusBoxcar) g_DataCube_boxcar_filter<<<gridSizeZ, blockSizeZ>>>(d_data, d_data_box, word_size, axis_size[0], axis_size[1], last_chunk_size, radiusBoxcar, 2);

            cudaDeviceSynchronize();

            // Error before Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error before Xkernel launch: %s\n", cudaGetErrorString(err));    
            }

            // Gauss Filter size in X Direction
            dim3 blockSizeX(ceil((float)32 / number_of_chunks),32);
            dim3 gridSizeX((last_chunk_size + blockSizeX.x - 1) / blockSizeX.x ,
                        (axis_size[1] + blockSizeX.y - 1) / blockSizeX.y);

            if (radiusGauss) g_DataCube_gauss_filter_XDir<<<gridSizeX, blockSizeX, axis_size[0] * sizeof(float) + (axis_size[0] + 2 * radiusGauss) * sizeof(float)>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], last_chunk_size, radiusGauss, n_iter);

            cudaDeviceSynchronize();

            // Error after Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after Xkernel launch: %s\n", cudaGetErrorString(err));    
            }

            // Gauss Filter in Y Direction
            dim3 blockSizeY(ceil((float)16 / number_of_chunks),16);
            dim3 gridSizeY((last_chunk_size + blockSizeY.x - 1) / blockSizeY.x,
                        (axis_size[0] + blockSizeY.y - 1) / blockSizeY.y);

            // Error before Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error before Ykernel launch: %s\n", cudaGetErrorString(err));    
            }

            if (radiusGauss) g_DataCube_gauss_filter_YDir<<<gridSizeY, blockSizeY>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], last_chunk_size, radiusGauss, n_iter);

            cudaDeviceSynchronize();

            // Error after Kernel Launch?
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after Ykernel launch: %s\n", cudaGetErrorString(err));    
            }

            cudaMemcpy(data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, d_data + radiusBoxcar * axis_size[0] * axis_size[1], last_chunk_size * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyDeviceToHost);
            // Error after backkcopy??
            err = cudaGetLastError();
            if (err != cudaSuccess)
            {
                printf("Cuda error after backcopy: %s\n", cudaGetErrorString(err));
            }
        }

        if (t == 0)
        {
            for (int i = 0; i < axis_size[0] * axis_size[1] * axis_size[2]; i++)
            {
                first_data[i] = ((float*)data)[i];
            }
        }
        else
        {
            for (int i = 0; i < axis_size[0] * axis_size[1] * axis_size[2]; i++)
            {
                second_data[i] = ((float*)data)[i];
            }        
        }

        cudaFree(d_data);
        cudaFree(d_data_box);

        // Error after free mem??
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
<<<<<<< HEAD
            printf("Cuda error after freeing memory: %s\n", cudaGetErrorString(err));    
=======
            printf("Cuda error at mem Copy to device: %s\n", cudaGetErrorString(err));    
        }

        // Boxcar Filter in Z Direction
        dim3 blockSizeZ(32,32);
        dim3 gridSizeZ((axis_size[0] + blockSizeZ.x - 1) / blockSizeZ.x,
                    (axis_size[1] + blockSizeZ.y - 1) / blockSizeZ.y);

        if (radiusBoxcar) g_DataCube_boxcar_filter<<<gridSizeZ, blockSizeZ>>>(d_data, originalData, d_data_box, word_size, processed_chunks * slices_per_chunk, axis_size[0], axis_size[1], slices_per_chunk, radiusBoxcar, 1);

        cudaDeviceSynchronize();
        
        // Error before Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error before Xkernel launch: %s\n", cudaGetErrorString(err));    
        }

        // Gauss Filter size in X Direction
        dim3 blockSizeX(ceil((float)32 / number_of_chunks),32);
        dim3 gridSizeX((slices_per_chunk + blockSizeX.x - 1) / blockSizeX.x ,
                    (axis_size[1] + blockSizeX.y - 1) / blockSizeX.y);

        if (radiusGauss) g_DataCube_gauss_filter_XDir<<<gridSizeX, blockSizeX, axis_size[0] * sizeof(float) + (axis_size[0] + 2 * radiusGauss) * sizeof(float)>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

        cudaDeviceSynchronize();

        // Error after Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after Xkernel launch: %s\n", cudaGetErrorString(err));    
        }

        // Gauss Filter in Y Direction
        dim3 blockSizeY(ceil((float)16 / number_of_chunks),16);
        dim3 gridSizeY((slices_per_chunk + blockSizeY.x - 1) / blockSizeY.x,
                    (axis_size[0] + blockSizeY.y - 1) / blockSizeY.y);

        // Error before Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error before Ykernel launch: %s\n", cudaGetErrorString(err));    
        }

        if (radiusGauss) g_DataCube_gauss_filter_YDir<<<gridSizeY, blockSizeY>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], slices_per_chunk, radiusGauss, n_iter);

        cudaDeviceSynchronize();

        // Error after Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after Ykernel launch: %s\n", cudaGetErrorString(err));    
        }

        cudaMemcpy(data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, d_data + radiusBoxcar * axis_size[0] * axis_size[1], slices_per_chunk * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyDeviceToHost);
        // Error after backkcopy??
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after backcopy: %s\n", cudaGetErrorString(err));
        }

        remaining_slices -= slices_per_chunk;

        processed_chunks++;
    }

    // err = cudaMalloc((void**)&d_data, data_size * word_size * sizeof(char));
    // if (err != cudaSuccess)
    // {
    //     printf("%s\n", cudaGetErrorString(err));
    //     exit(0);
    // }


    // err = cudaMalloc((void**)&d_data_box, (data_size + 
    //                                         (x_overlap > y_overlap ? (x_overlap > z_overlap ? x_overlap : z_overlap) 
    //                                         : (y_overlap > z_overlap ? y_overlap : z_overlap))) 
    //                                         * sizeof(float));
    // if (err != cudaSuccess)
    // {
    //     printf("%s\n", cudaGetErrorString(err));
    //     exit(0);
    // }

    // for (int i = 0; i < blockSizeX.x; i++)
    // {
    //     for (int j = 0; j < blockSizeX.y; j++)
    //     {
    //         cudaMemcpy(d_data 
    //                         + min(i * axis_size[0] * axis_size[1] * gridSizeX.x + (gridSizeX.x - 1) * axis_size[0] * axis_size[1], (axis_size[2]- 1) * axis_size[0] * axis_size[1])
    //                         + min(j * axis_size[0] * gridSizeX.y + (gridSizeX.y - 1) * axis_size[0], (axis_size[1] - 1) * axis_size[0])
    //                         + axis_size[0] - 1, 
    //                         &flag, sizeof(char), cudaMemcpyHostToDevice);
    //     }
    // }

    size_t last_chunk_size = remaining_slices;

    if (last_chunk_size > 0)
    {
        cudaMemcpy(d_data + radiusBoxcar * axis_size[0] * axis_size[1], data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, last_chunk_size * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyHostToDevice);
        // Error after mem copy?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error at last mem Copy to device: %s\n", cudaGetErrorString(err));    
        }

        // Boxcar Filter in Z Direction
        dim3 blockSizeZ(32,32);
        dim3 gridSizeZ((axis_size[0] + blockSizeZ.x - 1) / blockSizeZ.x,
                    (axis_size[1] + blockSizeZ.y - 1) / blockSizeZ.y);

        if (radiusBoxcar) g_DataCube_boxcar_filter<<<gridSizeZ, blockSizeZ>>>(d_data, originalData, d_data_box, word_size, processed_chunks * slices_per_chunk, axis_size[0], axis_size[1], last_chunk_size, radiusBoxcar, 2);

        cudaDeviceSynchronize();

        // Error before Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error before Xkernel launch: %s\n", cudaGetErrorString(err));    
        }

        // Gauss Filter size in X Direction
        dim3 blockSizeX(ceil((float)32 / number_of_chunks),32);
        dim3 gridSizeX((last_chunk_size + blockSizeX.x - 1) / blockSizeX.x ,
                    (axis_size[1] + blockSizeX.y - 1) / blockSizeX.y);

        if (radiusGauss) g_DataCube_gauss_filter_XDir<<<gridSizeX, blockSizeX, axis_size[0] * sizeof(float) + (axis_size[0] + 2 * radiusGauss) * sizeof(float)>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], last_chunk_size, radiusGauss, n_iter);

        cudaDeviceSynchronize();

        // Error after Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after Xkernel launch: %s\n", cudaGetErrorString(err));    
        }

        // Gauss Filter in Y Direction
        dim3 blockSizeY(ceil((float)16 / number_of_chunks),16);
        dim3 gridSizeY((last_chunk_size + blockSizeY.x - 1) / blockSizeY.x,
                    (axis_size[0] + blockSizeY.y - 1) / blockSizeY.y);

        // Error before Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error before Ykernel launch: %s\n", cudaGetErrorString(err));    
        }

        if (radiusGauss) g_DataCube_gauss_filter_YDir<<<gridSizeY, blockSizeY>>>(d_data + radiusBoxcar * axis_size[0] * axis_size[1], d_data_box, word_size, axis_size[0], axis_size[1], last_chunk_size, radiusGauss, n_iter);

        cudaDeviceSynchronize();

        // Error after Kernel Launch?
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after Ykernel launch: %s\n", cudaGetErrorString(err));    
        }

        cudaMemcpy(data + processed_chunks * slices_per_chunk * axis_size[0] * axis_size[1] * word_size, d_data + radiusBoxcar * axis_size[0] * axis_size[1], last_chunk_size * axis_size[0] * axis_size[1] * word_size * sizeof(char), cudaMemcpyDeviceToHost);
        // Error after backkcopy??
        err = cudaGetLastError();
        if (err != cudaSuccess)
        {
            printf("Cuda error after backcopy: %s\n", cudaGetErrorString(err));
>>>>>>> bdce042ff1840371ef4d3cefd8ade7ca3f97c624
        }
    }
    
    for (int i = 0; i < axis_size[0] * axis_size[1] * axis_size[2]; i++)
    {
        if (fabs(first_data[i] - second_data[i]) > 0.0000001) 
        {
            printf("Found Mistake at %i FirstData: %f SecondData: %f\n", i, first_data[i], second_data[i]);
            break;
        }
        
    }
}

__global__ void g_DataCube_boxcar_filter(float *data, char *originalData, float *data_box, int word_size, const size_t startSlice, size_t width, size_t height, size_t depth, size_t radius, size_t chunck_type)
{
    size_t x = blockIdx.x * blockDim.x + threadIdx.x;
    size_t y = blockIdx.y * blockDim.y + threadIdx.y;
    size_t jump = width * height;

    if (x < width && y < height)
    {
        data = data + (x + y * width);
        data_box = data_box + (x + y * width);

        d_filter_chunk_boxcar_1d_flt(data, originalData, data_box, startSlice, depth, radius, jump, chunck_type);
    }
}

__global__ void g_DataCube_gauss_filter_XDir(float *data, float *data_box, int word_size, size_t width, size_t height, size_t depth, size_t radius, size_t n_iter)
{
    size_t thread_count = blockDim.x * blockDim.y;
    size_t thread_index = threadIdx.x * blockDim.y + threadIdx.y;

    const size_t filter_size = 2 * radius + 1;
	const float inv_filter_size = 1.0 / filter_size;

    extern __shared__ float s_data[];
    float *s_data_box = &s_data[width];

    size_t start_index = blockIdx.x * blockDim.x * width * height + blockIdx.y * blockDim.y * width;    

    for (int iter = 0; iter < blockDim.x * blockDim.y; iter++)
    {
        if (blockIdx.y * blockDim.y + (iter % blockDim.y) >= height) continue;

        size_t data_index = start_index + (iter % blockDim.y) * width + (iter / blockDim.y) * width * height;

        if (data_index >= width * height * depth) continue;

        for (size_t i = 0; i < (float)width / thread_count; i++)
        {
            size_t j = thread_index + thread_count * i;
            if (j < width)
            {
                s_data[j] = s_data_box[radius + j] = data[data_index + j];
            }
        }

         for (int i = radius; i--;) s_data_box[i] = s_data_box[radius + width + i] = 0.0;

        __syncthreads();

        for (size_t k = n_iter; k--;)
        {
            for (int i = 0; i < (float)width / thread_count; i++)
            {
                int j = thread_index + thread_count * i;
                if (j < width)
                {
                    s_data[j] = 0.0;
                    for(int f = filter_size; f--;) s_data[j] += s_data_box[j + f];
                    s_data[j] *= inv_filter_size;
                }
            }

            __syncthreads();

            for (int i = 0; i < (float)width / thread_count; i++)
            {
                int j = thread_index + thread_count * i;
                if (j < width)
                {
                    s_data_box[radius + j] = s_data[j];
                }
            }

            __syncthreads();
        }

        for (int i = 0; i < width / (float)thread_count; i++)
        {
            int j = thread_index + thread_count * i;
            if (j < width)
            {
                data[data_index + j] = s_data[j];
            }
        }
    }
}

__global__ void g_DataCube_gauss_filter_YDir(float *data, float *data_box, int word_size, size_t width, size_t height, size_t depth, size_t radius, size_t n_iter)
{
    size_t x = blockIdx.x * blockDim.x + threadIdx.x;
    size_t y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < depth && y < width)
    {
        data = data + x * width * height + y;
        data_box = data_box + x * width * (height + 2 * radius) 
                            + y;

        for(size_t i = n_iter; i--;) d_filter_boxcar_1d_flt(data, data_box, height, radius, width);
    }
}


__device__ void d_filter_boxcar_1d_flt(float *data, float *data_copy, const size_t size, const size_t filter_radius, const size_t jump)
{
    // Define filter size
	const size_t filter_size = 2 * filter_radius + 1;
	const float inv_filter_size = 1.0 / filter_size;
	size_t i;

	// Make copy of data, taking care of NaN
	for(i = size; i--;) data_copy[(filter_radius + i) * jump] = FILTER_NAN(data[i * jump]);
	
	// Fill overlap regions with 0
	for(i = filter_radius; i--;) data_copy[i * jump] = data_copy[(size + filter_radius + i) * jump] = 0.0;
	
	// Apply boxcar filter to last data point
	data[(size - 1) * jump] = 0.0;
	for(i = filter_size; i--;) data[(size - 1) * jump] += data_copy[(size + i - 1) * jump];
	data[(size - 1) * jump] *= inv_filter_size;
	
	// Recursively apply boxcar filter to all previous data points
	for(i = size - 1; i--;) data[i * jump] = data[(i + 1) * jump] + (data_copy[i * jump] - data_copy[(filter_size + i) * jump]) * inv_filter_size;
	
	return;
}

__device__ void d_filter_chunk_boxcar_1d_flt(float *data, char *originalData, float *data_copy, const size_t startSlice, const size_t size, const size_t filter_radius, const size_t jump, size_t chunk_type)
{
    // Define filter size
	const size_t filter_size = 2 * filter_radius + 1;
	const float inv_filter_size = 1.0 / filter_size;
	size_t i;

    if (chunk_type != 2)
    {
        for(i = filter_radius; i--;) data_copy[i * jump] = FILTER_NAN(data[i * jump]);
        for(i = filter_radius; i--;) data_copy[(size + filter_radius + i) * jump] = FILTER_NAN(data[(size + filter_radius + i) * jump]);
    }
    else
    {
        for(i = filter_radius; i--;) data_copy[i * jump] = FILTER_NAN(data[i * jump]);
        for(i = filter_radius; i--;) data_copy[(size + filter_radius + i) * jump] = 0.0;
    }

    // // Fill overlap regions
    // if (chunk_type == 0)
    // {
    //     for(i = filter_radius; i--;) data_copy[i * jump] = 0.0;
    //     for(i = filter_radius; i--;) data_copy[(size + filter_radius + i) * jump] = FILTER_NAN(data[(size + filter_radius + i) * jump]);
    // }
    // else if (chunk_type == 1)
    // {
    //     for(i = filter_radius; i--;) data_copy[i * jump] = FILTER_NAN(data[i * jump]);
    //     for(i = filter_radius; i--;) data_copy[(size + filter_radius + i) * jump] = FILTER_NAN(data[(size + filter_radius + i) * jump]);
    // }
    // else if (chunk_type == 2)
    // {
    //     for(i = filter_radius; i--;) data_copy[i * jump] = FILTER_NAN(data[i * jump]);
    //     for(i = filter_radius; i--;) data_copy[(size + filter_radius + i) * jump] = 0.0;
    // }

    // Write elements at the end of the data chunk back to the front end overlap for next chunk
    if (chunk_type != 2)
    {
        for(i = 0; i < filter_radius; i++) data[i * jump] = data[(size + i) * jump];
    }

	// Make copy of data, taking care of NaN
	for(i = size; i--;) data_copy[(filter_radius + i) * jump] = FILTER_NAN(data[(filter_radius + i) * jump]);
	
	// Apply boxcar filter to last data point
	data[(size + filter_radius - 1) * jump] = 0.0;
	for(i = filter_size; i--;) data[(size + filter_radius - 1) * jump] += data_copy[(size + i - 1) * jump];
	data[(size + filter_radius - 1) * jump] *= inv_filter_size;
	
	// Recursively apply boxcar filter to all previous data points
	for(i = size - 1; i--;) data[(filter_radius + i) * jump] = data[(filter_radius + i + 1) * jump] + (data_copy[i * jump] - data_copy[(filter_size + i) * jump]) * inv_filter_size;
	
	return;
}