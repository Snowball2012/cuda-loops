
#include <dvmhlib_cuda.h>
#define dcmplx2 Complex<double>
#define cmplx2 Complex<float>

      
      
      

//--------------------- Kernel for loop on line 16 ---------------------

         __global__ void   loop_adi_16_cuda_kernel_1_case(double a[], CudaIndexType a0003, CudaIndexType a0002, DvmType num_elem_j, DvmType num_elem_k, DvmType base_i, DvmType base_j, DvmType base_k, DvmType step_i, DvmType step_j, DvmType step_k, DvmType type_of_run, DvmType idxs_0, DvmType idxs_1, DvmType idxs_2){
            DvmType id_x, id_y;
            DvmType coords[3];

// Local needs
            int k, j, i;
            id_x = blockIdx.x * blockDim.x + threadIdx.x;
            id_y = blockIdx.y * blockDim.y + threadIdx.y;
            if (id_x < num_elem_j && id_y < num_elem_k) 
            {
               coords[idxs_0] = base_i;
               coords[idxs_1] = base_j + id_x * step_j;
               coords[idxs_2] = base_k + id_y * step_k;
               i = coords[0];
               j = coords[1];
               k = coords[2];

// Loop body
               a[i + a0003 * j + a0002 * k] = (a[i - 1 + a0003 * j + a0002 * k] + a[i + 1 + a0003 * j + a0002 * k]) / 2;
            }
         }


//--------------------- Kernel for loop on line 24 ---------------------

         __global__ void   loop_adi_24_cuda_kernel_1_case(double a[], CudaIndexType a0003, CudaIndexType a0002, DvmType num_elem_j, DvmType num_elem_k, DvmType base_i, DvmType base_j, DvmType base_k, DvmType step_i, DvmType step_j, DvmType step_k, DvmType type_of_run, DvmType idxs_0, DvmType idxs_1, DvmType idxs_2){
            DvmType id_x, id_y;
            DvmType coords[3];

// Local needs
            int k, j, i;
            id_x = blockIdx.x * blockDim.x + threadIdx.x;
            id_y = blockIdx.y * blockDim.y + threadIdx.y;
            if (id_x < num_elem_j && id_y < num_elem_k) 
            {
               coords[idxs_0] = base_i;
               coords[idxs_1] = base_j + id_x * step_j;
               coords[idxs_2] = base_k + id_y * step_k;
               i = coords[0];
               j = coords[1];
               k = coords[2];

// Loop body
               a[i + a0003 * j + a0002 * k] = (a[i + a0003 * (j - 1) + a0002 * k] + a[i + a0003 * (j + 1) + a0002 * k]) / 2;
            }
         }


//--------------------- Kernel for loop on line 33 ---------------------

         __global__ void   loop_adi_33_cuda_kernel_1_case(double a[], CudaIndexType a0003, CudaIndexType a0002, double eps, double eps_grid[], DvmType num_elem_j, DvmType num_elem_k, DvmType base_i, DvmType base_j, DvmType base_k, DvmType step_i, DvmType step_j, DvmType step_k, DvmType type_of_run, DvmType idxs_0, DvmType idxs_1, DvmType idxs_2){
            DvmType id_x, id_y;
            DvmType coords[3];

// Local needs
            int k, j, i;
            extern __shared__ double eps_block[];
            id_x = blockIdx.x * blockDim.x + threadIdx.x;
            id_y = blockIdx.y * blockDim.y + threadIdx.y;
            if (id_x < num_elem_j && id_y < num_elem_k) 
            {
               coords[idxs_0] = base_i;
               coords[idxs_1] = base_j + id_x * step_j;
               coords[idxs_2] = base_k + id_y * step_k;
               i = coords[0];
               j = coords[1];
               k = coords[2];

// Loop body
               eps = max(eps, fabs(a[i + a0003 * j + a0002 * k] - (a[i + a0003 * j + a0002 * (k - 1)] + a[i + a0003 * j + a0002 * (k + 1)]) / 2));
               a[i + a0003 * j + a0002 * k] = (a[i + a0003 * j + a0002 * (k - 1)] + a[i + a0003 * j + a0002 * (k + 1)]) / 2;
            }
            id_x = blockDim.x * blockDim.y * blockDim.z / 2;

// Reduction
            i = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * (blockDim.x * blockDim.y);
            eps_block[i] = eps;
            __syncthreads();
            j = id_x;
            while (j >= 1)
            {
               __syncthreads();
               if (i < j) 
               {
                  eps_block[i] = max(eps_block[i], eps_block[i + j]);
               }
               j = j / 2;
            }
            if (i == 0) 
            {
               eps_grid[blockIdx.x + (blockIdx.y + blockIdx.z * gridDim.y) * gridDim.x] = max(eps_grid[blockIdx.x + (blockIdx.y + blockIdx.z * gridDim.y) * gridDim.x], eps_block[0]);
            }
         }


//--------------------- Kernel for loop on line 74 ---------------------

         __global__ void   loop_adi_74_cuda_kernel(double a[], CudaIndexType a0003, CudaIndexType a0002, CudaIndexType blocks[], int nz, int ny, int nx){

// Local needs
            CudaIndexType k, j, i;
            int ibof;

// Calculate each thread's loop variables' values
            ibof = blockIdx.x * 6;
            k = blocks[ibof + 0] + threadIdx.z;
            if (k <= blocks[ibof + 1]) 
            {
               j = blocks[ibof + 2] + threadIdx.y;
               if (j <= blocks[ibof + 3]) 
               {
                  i = blocks[ibof + 4] + threadIdx.x;
                  if (i <= blocks[ibof + 5]) 
                  {

// Loop body
                     if (k == 1 | k == nz | j == 1 | j == ny | i == 1 | i == nx) 
                     {
                        a[i + a0003 * j + a0002 * k] = 10. * (i - 1) / (nx - 1) + 10. * (j - 1) / (ny - 1) + 10. * (k - 1) / (nz - 1);
                     }
                     else{
                        a[i + a0003 * j + a0002 * k] = 0.000000e+00;
                     }
                  }
               }
            }
         }

      

#ifdef _MS_F_
#define loop_adi_16_cuda_ loop_adi_16_cuda
#define loop_adi_24_cuda_ loop_adi_24_cuda
#define loop_adi_33_cuda_ loop_adi_33_cuda
#define loop_adi_74_cuda_ loop_adi_74_cuda
#endif
#include <cstdio>
#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))
#define MAX(X,Y) ((X) > (Y) ? (X) : (Y))

      extern "C" {
         extern  DvmType loop_adi_74_cuda_kernel_regs, loop_adi_33_1_case_regs, loop_adi_24_1_case_regs, loop_adi_16_1_case_regs;


//    CUDA handler for loop on line 16 

         void   loop_adi_16_cuda_1_case(DvmhLoopRef *loop_ref, DvmType a[], DvmType type_of_run){
            void   *a_base;
            DvmType d_a[6];
            cudaStream_t stream;
            DvmType shared_mem;
            dim3 blocks, threads;
            int base_i, base_j, base_k;
            DvmType num_elem_y;
            DvmType num_elem_x;
            DvmType num_y;
            DvmType num_x;
            DvmType idxs[5];
            DvmType lowI[5], highI[5], idxI[5];
            DvmType device_num;

// Get device number
            device_num = loop_get_device_num_(loop_ref);

// Get natural bases
            a_base = dvmh_get_natural_base(&device_num, a);

// Fill device headers
            dvmh_fill_header_(&device_num, a_base, a, d_a);

// Get bounds
            loop_fill_bounds_(loop_ref, lowI, highI, idxI);

// Swap bounds
            dvmh_change_filled_bounds(lowI, highI, idxI, 3, 1, type_of_run, idxs);

// Get cuda config params
            threads = dim3(32, 8, 1);
            shared_mem = 0;
            loop_cuda_get_config(loop_ref, shared_mem, loop_adi_16_1_case_regs, &threads, &stream, &shared_mem);
            num_x = threads.x;
            num_y = threads.y;

//Start method
            blocks = dim3(1, 1, 1);
            base_i = lowI[2];
            base_j = lowI[1];
            num_elem_x = (abs(lowI[1] - highI[1]) + 1) / abs(idxI[1]) + ((abs(lowI[1] - highI[1]) + 1) % abs(idxI[1]) != 0);
            blocks.x = num_elem_x / num_x + (num_elem_x % num_x != 0);
            threads.x = num_x;
            base_k = lowI[0];
            num_elem_y = (abs(lowI[0] - highI[0]) + 1) / abs(idxI[0]) + ((abs(lowI[0] - highI[0]) + 1) % abs(idxI[0]) != 0);
            blocks.y = num_elem_y / num_y + (num_elem_y % num_y != 0);
            threads.y = num_y;
            highI[2] = (abs(highI[2] - lowI[2]) + 1) / abs(idxI[2]);
            for (int tmpV = 0 ; tmpV < highI[2] ; base_i = base_i + idxI[2], tmpV = tmpV + 1)
            {
               loop_adi_16_cuda_kernel_1_case<<<blocks, threads, shared_mem, stream>>>((double *)a_base, d_a[2], d_a[1], num_elem_x, num_elem_y, base_i, base_j, base_k, idxI[2], idxI[1], idxI[0], type_of_run, idxs[0], idxs[1], idxs[2]);
            }
         }


//    CUDA handler for loop on line 16 

         void   loop_adi_16_cuda_(DvmhLoopRef *loop_ref, DvmType a[]){
            int which_run;
            which_run = loop_get_dependency_mask_(loop_ref);
            if (which_run == 1 || which_run == 2 || which_run == 4) 
            {
               loop_adi_16_cuda_1_case(loop_ref, a, which_run);
            }
         }


//    CUDA handler for loop on line 24 

         void   loop_adi_24_cuda_1_case(DvmhLoopRef *loop_ref, DvmType a[], DvmType type_of_run){
            void   *a_base;
            DvmType d_a[6];
            cudaStream_t stream;
            DvmType shared_mem;
            dim3 blocks, threads;
            int base_i, base_j, base_k;
            DvmType num_elem_y;
            DvmType num_elem_x;
            DvmType num_y;
            DvmType num_x;
            DvmType idxs[5];
            DvmType lowI[5], highI[5], idxI[5];
            DvmType device_num;

// Get device number
            device_num = loop_get_device_num_(loop_ref);

// Get natural bases
            a_base = dvmh_get_natural_base(&device_num, a);

// Fill device headers
            dvmh_fill_header_(&device_num, a_base, a, d_a);

// Get bounds
            loop_fill_bounds_(loop_ref, lowI, highI, idxI);

// Swap bounds
            dvmh_change_filled_bounds(lowI, highI, idxI, 3, 1, type_of_run, idxs);

// Get cuda config params
            threads = dim3(32, 8, 1);
            shared_mem = 0;
            loop_cuda_get_config(loop_ref, shared_mem, loop_adi_24_1_case_regs, &threads, &stream, &shared_mem);
            num_x = threads.x;
            num_y = threads.y;

//Start method
            blocks = dim3(1, 1, 1);
            base_i = lowI[2];
            base_j = lowI[1];
            num_elem_x = (abs(lowI[1] - highI[1]) + 1) / abs(idxI[1]) + ((abs(lowI[1] - highI[1]) + 1) % abs(idxI[1]) != 0);
            blocks.x = num_elem_x / num_x + (num_elem_x % num_x != 0);
            threads.x = num_x;
            base_k = lowI[0];
            num_elem_y = (abs(lowI[0] - highI[0]) + 1) / abs(idxI[0]) + ((abs(lowI[0] - highI[0]) + 1) % abs(idxI[0]) != 0);
            blocks.y = num_elem_y / num_y + (num_elem_y % num_y != 0);
            threads.y = num_y;
            highI[2] = (abs(highI[2] - lowI[2]) + 1) / abs(idxI[2]);
            for (int tmpV = 0 ; tmpV < highI[2] ; base_i = base_i + idxI[2], tmpV = tmpV + 1)
            {
               loop_adi_24_cuda_kernel_1_case<<<blocks, threads, shared_mem, stream>>>((double *)a_base, d_a[2], d_a[1], num_elem_x, num_elem_y, base_i, base_j, base_k, idxI[2], idxI[1], idxI[0], type_of_run, idxs[0], idxs[1], idxs[2]);
            }
         }


//    CUDA handler for loop on line 24 

         void   loop_adi_24_cuda_(DvmhLoopRef *loop_ref, DvmType a[]){
            int which_run;
            which_run = loop_get_dependency_mask_(loop_ref);
            if (which_run == 1 || which_run == 2 || which_run == 4) 
            {
               loop_adi_24_cuda_1_case(loop_ref, a, which_run);
            }
         }


//    CUDA handler for loop on line 33 

         void   loop_adi_33_cuda_1_case(DvmhLoopRef *loop_ref, DvmType a[], DvmType type_of_run){
            void   *a_base;
            DvmType d_a[6];
            cudaStream_t stream;
            DvmType shared_mem;
            dim3 blocks, threads;
            int base_i, base_j, base_k;
            DvmType num_elem_y;
            DvmType num_elem_x;
            DvmType num_y;
            DvmType num_x;
            DvmType idxs[5];
            DvmType lowI[5], highI[5], idxI[5];
            DvmType num_of_red_blocks;
            double  *cuda_ptr_0;
            double eps;
            DvmType tmpVar1;
            DvmType tmpVar;
            DvmType device_num;

// Get device number
            device_num = loop_get_device_num_(loop_ref);

// Register reduction for CUDA-execution
            tmpVar = 1;
            loop_cuda_register_red(loop_ref, tmpVar, (void  **)&cuda_ptr_0, 0);
            loop_red_init_(loop_ref, &tmpVar, &eps, 0);

// Get natural bases
            a_base = dvmh_get_natural_base(&device_num, a);

// Fill device headers
            dvmh_fill_header_(&device_num, a_base, a, d_a);

// Get bounds
            loop_fill_bounds_(loop_ref, lowI, highI, idxI);

// Swap bounds
            dvmh_change_filled_bounds(lowI, highI, idxI, 3, 1, type_of_run, idxs);

// Get cuda config params
            threads = dim3(32, 8, 1);
            shared_mem = 8;
            loop_cuda_get_config(loop_ref, shared_mem, loop_adi_33_1_case_regs, &threads, &stream, &shared_mem);
            num_x = threads.x;
            num_y = threads.y;

//Start method
            blocks = dim3(1, 1, 1);
            base_i = lowI[2];
            base_j = lowI[1];
            num_elem_x = (abs(lowI[1] - highI[1]) + 1) / abs(idxI[1]) + ((abs(lowI[1] - highI[1]) + 1) % abs(idxI[1]) != 0);
            blocks.x = num_elem_x / num_x + (num_elem_x % num_x != 0);
            threads.x = num_x;
            base_k = lowI[0];
            num_elem_y = (abs(lowI[0] - highI[0]) + 1) / abs(idxI[0]) + ((abs(lowI[0] - highI[0]) + 1) % abs(idxI[0]) != 0);
            blocks.y = num_elem_y / num_y + (num_elem_y % num_y != 0);
            threads.y = num_y;
            num_of_red_blocks = blocks.x * blocks.y * blocks.z;
            tmpVar1 = 1;
            tmpVar = 1;
            loop_cuda_red_prepare(loop_ref, tmpVar, num_of_red_blocks, tmpVar1);
            highI[2] = (abs(highI[2] - lowI[2]) + 1) / abs(idxI[2]);
            for (int tmpV = 0 ; tmpV < highI[2] ; base_i = base_i + idxI[2], tmpV = tmpV + 1)
            {
               loop_adi_33_cuda_kernel_1_case<<<blocks, threads, shared_mem, stream>>>((double *)a_base, d_a[2], d_a[1], eps, cuda_ptr_0, num_elem_x, num_elem_y, base_i, base_j, base_k, idxI[2], idxI[1], idxI[0], type_of_run, idxs[0], idxs[1], idxs[2]);
            }
            tmpVar = 1;
            loop_red_finish(loop_ref, tmpVar);
         }


//    CUDA handler for loop on line 33 

         void   loop_adi_33_cuda_(DvmhLoopRef *loop_ref, DvmType a[]){
            int which_run;
            which_run = loop_get_dependency_mask_(loop_ref);
            if (which_run == 1 || which_run == 2 || which_run == 4) 
            {
               loop_adi_33_cuda_1_case(loop_ref, a, which_run);
            }
         }


//    CUDA handler for loop on line 74 

         void   loop_adi_74_cuda_(DvmhLoopRef *loop_ref, DvmType a[], int *nz, int *ny, int *nx){
            void   *a_base;
            DvmType d_a[6];
            dim3 blocks, threads;
            cudaStream_t stream;
            CudaIndexType  *blocks_info;
            DvmType device_num;

// Get device number
            device_num = loop_get_device_num_(loop_ref);

// Get 'natural' bases
            a_base = dvmh_get_natural_base(&device_num, a);

// Fill 'device' headers
            dvmh_fill_header_(&device_num, a_base, a, d_a);

// Get CUDA configuration parameters
            threads = dim3(0, 0, 0);
            loop_cuda_get_config(loop_ref, 0, loop_adi_74_cuda_kernel_regs, &threads, &stream, 0);

// GPU execution
            while (loop_cuda_do(loop_ref, &blocks, &blocks_info) != 0)
            {
               loop_adi_74_cuda_kernel<<<blocks, threads, 0, stream>>>((double *)a_base, d_a[2], d_a[1], blocks_info, *nz, *ny, *nx);
            }
         }

      }
