#include <cassert>

/* DVMH includes */
#include <dvmhlib2.h>
#include <curand_mtgp32_kernel.h>

int where_dep(int n, DvmType type_of_run, DvmType *idxs, int dep) {
    int count = 0;
    int h = 0;
    int hd = dep;
    for (int i = n - 1; i >= 0; --i) {
        if (type_of_run % 2 != 0) {
            count++;
            idxs[h] = i;
            h++;
        } else {
            idxs[hd] = i;
            hd++;
        }
        type_of_run = type_of_run / 2;
    }
    return count;
}




__global__ void loop_adi_41_cuda_kernel(double a_gen_0[], DvmType a_gen_0_hdr_gen_01, DvmType a_gen_0_hdr_gen_02, DvmType a_gen_0_hdr_gen_03, DvmType num_elem_x, DvmType base_i, DvmType loopSteps_2, DvmType idxs_2, DvmType num_elem_y, DvmType base_j, DvmType loopSteps_1, DvmType idxs_1, DvmType base_k, DvmType loopSteps_0, DvmType idxs_0)
{
    double* a_gen_0_base_gen_0 = a_gen_0;

    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    DvmType coords[3];
    DvmType id_x, id_y;
    DvmType red_idx1, red_idx2;

    id_x = blockIdx.x * blockDim.x + threadIdx.x;
    id_y = blockIdx.y * blockDim.y + threadIdx.y;

    if (id_x < num_elem_x && id_y < num_elem_y) {
        coords[idxs_0] = base_i;
        coords[idxs_1] = base_j + id_x * loopSteps_2;
        coords[idxs_2] = basdeie_k + id_y * loopSteps_1;
        i = coords[0];
        j = coords[1];
        k = coords[2];

        {
                a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] = (a_gen_0_base_gen_0[(i - 1)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] + a_gen_0_base_gen_0[(i + 1)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)]) / 2;
            }
    }
}

extern "C" void loop_adi_41_cuda_across(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[], int dep_mask)
{
    DvmType tmpVar;

    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    dvmh_loop_autotransform_C(loop_ref, a_gen_0_hdr_gen_0);    double * a_gen_0 = (double *)
        dvmh_get_natural_base_C(device_num, a_gen_0_hdr_gen_0);
    DvmType a_gen_0_devHdr_gen_0[6];
    tmpVar = dvmh_fill_header_C(device_num, a_gen_0, a_gen_0_hdr_gen_0, a_gen_0_devHdr_gen_0, 0);
    assert(tmpVar == 0 || tmpVar == 1);

    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3], idxs[3];
    DvmType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_41_cuda_kernel_int_regs;
    DvmType shared_mem = 0;
    dvmh_loop_cuda_get_config_C(loop_ref, shared_mem, loop_adi_41_cuda_kernel_int_regs,
        &threads, &stream, &shared_mem);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    where_dep(3, dep_mask, idxs, 1);

    DvmType base_i = boundsLow[2];
    DvmType num_elem_x = (abs(boundsLow[1] - boundsHigh[1]) + 1) / abs(loopSteps[1]) + ((abs(boundsLow[1] - boundsHigh[1]) + 1) % abs(loopSteps[1]) != 0);
    blocks.x = num_elem_x / threads.x + ((num_elem_x % threads.x != 0)?1:0);
    DvmType base_j = boundsLow[1];
    DvmType num_elem_y = (abs(boundsLow[0] - boundsHigh[0]) + 1) / abs(loopSteps[0]) + ((abs(boundsLow[0] - boundsHigh[0]) + 1) % abs(loopSteps[0]) != 0);
    blocks.y = num_elem_y / threads.y + ((num_elem_y % threads.y != 0)?1:0);
    DvmType base_k = boundsLow[0];

    boundsHigh[2] = (abs(boundsHigh[2] - boundsLow[2]) + 1) / abs(loopSteps[2]);

    /* Reduction-related stuff */

    /* GPU execution */
    for (int tmpV = 0; tmpV < boundsHigh[2]; base_i += loopSteps[2], tmpV++) {
        loop_adi_41_cuda_kernel<<<blocks, threads, shared_mem, stream>>>(a_gen_0, a_gen_0_devHdr_gen_0[1], a_gen_0_devHdr_gen_0[2], a_gen_0_devHdr_gen_0[3], num_elem_x, base_i, loopSteps[2], idxs[2], num_elem_y, base_j, loopSteps[1], idxs[1], base_k, loopSteps[0], idxs[0]);
    }
}


extern "C" void loop_adi_41_cuda(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[])
{
    int dep_mask = dvmh_loop_get_dependency_mask_C(*pLoopRef);
    if (dep_mask == 1 || dep_mask == 2 || dep_mask == 4) {
        loop_adi_41_cuda_across(pLoopRef, a_gen_0_hdr_gen_0, dep_mask);
    }
}

__global__ void loop_adi_46_cuda_kernel(double a_gen_0[], DvmType a_gen_0_hdr_gen_01, DvmType a_gen_0_hdr_gen_02, DvmType a_gen_0_hdr_gen_03, DvmType num_elem_x, DvmType base_i, DvmType loopSteps_2, DvmType idxs_2, DvmType num_elem_y, DvmType base_j, DvmType loopSteps_1, DvmType idxs_1, DvmType base_k, DvmType loopSteps_0, DvmType idxs_0)
{
    double* a_gen_0_base_gen_0 = a_gen_0;

    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    DvmType coords[3];
    DvmType id_x, id_y;
    DvmType red_idx1, red_idx2;

    id_x = blockIdx.x * blockDim.x + threadIdx.x;
    id_y = blockIdx.y * blockDim.y + threadIdx.y;

    if (id_x < num_elem_x && id_y < num_elem_y) {
        coords[idxs_0] = base_i;
        coords[idxs_1] = base_j + id_x * loopSteps_2;
        coords[idxs_2] = base_k + id_y * loopSteps_1;
        i = coords[0];
        j = coords[1];
        k = coords[2];

        {
                a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] = (a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j - 1)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] + a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j + 1)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)]) / 2;
            }
    }
}

extern "C" void loop_adi_46_cuda_across(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[], int dep_mask)
{
    DvmType tmpVar;

    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    dvmh_loop_autotransform_C(loop_ref, a_gen_0_hdr_gen_0);    double * a_gen_0 = (double *)
        dvmh_get_natural_base_C(device_num, a_gen_0_hdr_gen_0);
    DvmType a_gen_0_devHdr_gen_0[6];
    tmpVar = dvmh_fill_header_C(device_num, a_gen_0, a_gen_0_hdr_gen_0, a_gen_0_devHdr_gen_0, 0);
    assert(tmpVar == 0 || tmpVar == 1);

    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3], idxs[3];
    DvmType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_46_cuda_kernel_int_regs;
    DvmType shared_mem = 0;
    dvmh_loop_cuda_get_config_C(loop_ref, shared_mem, loop_adi_46_cuda_kernel_int_regs,
        &threads, &stream, &shared_mem);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    where_dep(3, dep_mask, idxs, 1);

    DvmType base_i = boundsLow[2];
    DvmType num_elem_x = (abs(boundsLow[1] - boundsHigh[1]) + 1) / abs(loopSteps[1]) + ((abs(boundsLow[1] - boundsHigh[1]) + 1) % abs(loopSteps[1]) != 0);
    blocks.x = num_elem_x / threads.x + ((num_elem_x % threads.x != 0)?1:0);
    DvmType base_j = boundsLow[1];
    DvmType num_elem_y = (abs(boundsLow[0] - boundsHigh[0]) + 1) / abs(loopSteps[0]) + ((abs(boundsLow[0] - boundsHigh[0]) + 1) % abs(loopSteps[0]) != 0);
    blocks.y = num_elem_y / threads.y + ((num_elem_y % threads.y != 0)?1:0);
    DvmType base_k = boundsLow[0];

    boundsHigh[2] = (abs(boundsHigh[2] - boundsLow[2]) + 1) / abs(loopSteps[2]);

    /* Reduction-related stuff */

    /* GPU execution */
    for (int tmpV = 0; tmpV < boundsHigh[2]; base_i += loopSteps[2], tmpV++) {
        loop_adi_46_cuda_kernel<<<blocks, threads, shared_mem, stream>>>(a_gen_0, a_gen_0_devHdr_gen_0[1], a_gen_0_devHdr_gen_0[2], a_gen_0_devHdr_gen_0[3], num_elem_x, base_i, loopSteps[2], idxs[2], num_elem_y, base_j, loopSteps[1], idxs[1], base_k, loopSteps[0], idxs[0]);
    }
}


extern "C" void loop_adi_46_cuda(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[])
{
    int dep_mask = dvmh_loop_get_dependency_mask_C(*pLoopRef);
    if (dep_mask == 1 || dep_mask == 2 || dep_mask == 4) {
        loop_adi_46_cuda_across(pLoopRef, a_gen_0_hdr_gen_0, dep_mask);
    }
}

__global__ void loop_adi_51_cuda_kernel(double a_gen_0[], DvmType a_gen_0_hdr_gen_01, DvmType a_gen_0_hdr_gen_02, DvmType a_gen_0_hdr_gen_03, DvmType num_elem_x, DvmType base_i, DvmType loopSteps_2, DvmType idxs_2, DvmType num_elem_y, DvmType base_j, DvmType loopSteps_1, DvmType idxs_1, DvmType base_k, DvmType loopSteps_0, DvmType idxs_0, double eps, double * eps_grid)
{
    double* a_gen_0_base_gen_0 = a_gen_0;

    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;
    extern __shared__ double eps_block[];

    DvmType coords[3];
    DvmType id_x, id_y;
    DvmType red_idx1, red_idx2;

    id_x = blockIdx.x * blockDim.x + threadIdx.x;
    id_y = blockIdx.y * blockDim.y + threadIdx.y;

    if (id_x < num_elem_x && id_y < num_elem_y) {
        coords[idxs_0] = base_i;
        coords[idxs_1] = base_j + id_x * loopSteps_2;
        coords[idxs_2] = base_k + id_y * loopSteps_1;
        i = coords[0];
        j = coords[1];
        k = coords[2];

        {
              double tmp1 = (a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k - 1)*(a_gen_0_hdr_gen_03)] + a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k + 1)*(a_gen_0_hdr_gen_03)]) / 2;
              double tmp2 = fabs(a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] - tmp1);
              eps = ((eps) > (tmp2) ? (eps) : (tmp2));
              a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] = tmp1;
            }
    }

// Reduction for var eps
    id_x = blockDim.x * blockDim.y * blockDim.z / 2;
    red_idx1 = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * (blockDim.x * blockDim.y);
    eps_block[red_idx1] = eps;
    __syncthreads();
    red_idx2 = id_x;
    while (red_idx2 >= 1) {;
        __syncthreads();
        if (red_idx1 < red_idx2) {
            eps_block[red_idx1] = max(eps_block[red_idx1], eps_block[red_idx1 + red_idx2]);        }
            red_idx2 = red_idx2 / 2;
    }
    if (red_idx1 == 0) {
        eps_grid[blockIdx.x + (blockIdx.y + blockIdx.z * gridDim.y) * gridDim.x] = max(eps_grid[blockIdx.x + (blockIdx.y + blockIdx.z * gridDim.y) * gridDim.x], eps_block[0]);
    }
}

extern "C" void loop_adi_51_cuda_across(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[], int dep_mask)
{
    DvmType tmpVar;

    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    dvmh_loop_autotransform_C(loop_ref, a_gen_0_hdr_gen_0);    double * a_gen_0 = (double *)
        dvmh_get_natural_base_C(device_num, a_gen_0_hdr_gen_0);
    DvmType a_gen_0_devHdr_gen_0[6];
    tmpVar = dvmh_fill_header_C(device_num, a_gen_0, a_gen_0_hdr_gen_0, a_gen_0_devHdr_gen_0, 0);
    assert(tmpVar == 0 || tmpVar == 1);

    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3], idxs[3];
    DvmType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_51_cuda_kernel_int_regs;
    DvmType shared_mem = 16;
    dvmh_loop_cuda_get_config_C(loop_ref, shared_mem, loop_adi_51_cuda_kernel_int_regs,
        &threads, &stream, &shared_mem);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    where_dep(3, dep_mask, idxs, 1);

    DvmType base_i = boundsLow[2];
    DvmType num_elem_x = (abs(boundsLow[1] - boundsHigh[1]) + 1) / abs(loopSteps[1]) + ((abs(boundsLow[1] - boundsHigh[1]) + 1) % abs(loopSteps[1]) != 0);
    blocks.x = num_elem_x / threads.x + ((num_elem_x % threads.x != 0)?1:0);
    DvmType base_j = boundsLow[1];
    DvmType num_elem_y = (abs(boundsLow[0] - boundsHigh[0]) + 1) / abs(loopSteps[0]) + ((abs(boundsLow[0] - boundsHigh[0]) + 1) % abs(loopSteps[0]) != 0);
    blocks.y = num_elem_y / threads.y + ((num_elem_y % threads.y != 0)?1:0);
    DvmType base_k = boundsLow[0];

    boundsHigh[2] = (abs(boundsHigh[2] - boundsLow[2]) + 1) / abs(loopSteps[2]);

    /* Reduction-related stuff */
    double eps;
    double * eps_grid;
    dvmh_loop_cuda_register_red_C(loop_ref, 1, (void**)&eps_grid, 0);
    dvmh_loop_red_init_C(loop_ref, 1, &eps, 0);
    dvmh_loop_cuda_red_prepare_C(loop_ref, 1, blocks.x * blocks.y * blocks.z, 1);

    /* GPU execution */
    for (int tmpV = 0; tmpV < boundsHigh[2]; base_i += loopSteps[2], tmpV++) {
        loop_adi_51_cuda_kernel<<<blocks, threads, shared_mem, stream>>>(a_gen_0, a_gen_0_devHdr_gen_0[1], a_gen_0_devHdr_gen_0[2], a_gen_0_devHdr_gen_0[3], num_elem_x, base_i, loopSteps[2], idxs[2], num_elem_y, base_j, loopSteps[1], idxs[1], base_k, loopSteps[0], idxs[0], eps, eps_grid);
    }
    dvmh_loop_cuda_red_finish_C(loop_ref, 1);
}


extern "C" void loop_adi_51_cuda(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[])
{
    int dep_mask = dvmh_loop_get_dependency_mask_C(*pLoopRef);
    if (dep_mask == 1 || dep_mask == 2 || dep_mask == 4) {
        loop_adi_51_cuda_across(pLoopRef, a_gen_0_hdr_gen_0, dep_mask);
    }
}

__global__ void loop_adi_92_cuda_kernel(double a_gen_0[], DvmType a_gen_0_hdr_gen_01, DvmType a_gen_0_hdr_gen_02, DvmType a_gen_0_hdr_gen_03, DvmType boundsLow_1, DvmType boundsHigh_1, DvmType loopSteps_1, DvmType boundsLow_2, DvmType boundsHigh_2, DvmType loopSteps_2, DvmType blocksS_2, DvmType boundsLow_3, DvmType boundsHigh_3, DvmType loopSteps_3, DvmType blocksS_3, DvmType blockOffset)
{
    double* a_gen_0_base_gen_0 = a_gen_0;
    DvmType restBlocks, curBlocks;

    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    restBlocks = blockIdx.x + blockOffset;
    curBlocks = restBlocks / blocksS_2;
    i = boundsLow_1 + (loopSteps_1) * ( curBlocks * blockDim.z + threadIdx.z);
    if (i <= boundsHigh_1)  {
        restBlocks = restBlocks - curBlocks * blocksS_2;
        curBlocks = restBlocks / blocksS_3;
        j = boundsLow_2 + (loopSteps_2) * ( curBlocks * blockDim.y + threadIdx.y);
        if (j <= boundsHigh_2)  {
            restBlocks = restBlocks - curBlocks * blocksS_3;
            curBlocks = restBlocks;
            k = boundsLow_3 + (loopSteps_3) * ( curBlocks * blockDim.x + threadIdx.x);
            if (k <= boundsHigh_3) 
            {
                if (k == 0 || k == 384 - 1 || j == 0 || j == 384 - 1 || i == 0 || i == 384 - 1)
                  a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] = 10. * i / (384 - 1) + 10. * j / (384 - 1) + 10. * k / (384 - 1);
                else
                  a_gen_0_base_gen_0[(i)*(a_gen_0_hdr_gen_01) + (j)*(a_gen_0_hdr_gen_02) + (k)*(a_gen_0_hdr_gen_03)] = 0;
            }
        }
    }
}

extern "C" void loop_adi_92_cuda(DvmType *pLoopRef, DvmType a_gen_0_hdr_gen_0[])
{
    DvmType tmpVar;

    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    dvmh_loop_autotransform_C(loop_ref, a_gen_0_hdr_gen_0);    double * a_gen_0 = (double *)
        dvmh_get_natural_base_C(device_num, a_gen_0_hdr_gen_0);
    DvmType a_gen_0_devHdr_gen_0[6];
    tmpVar = dvmh_fill_header_C(device_num, a_gen_0, a_gen_0_hdr_gen_0, a_gen_0_devHdr_gen_0, 0);
    assert(tmpVar == 0 || tmpVar == 1);

    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    DvmType blocksS[3];
    DvmType restBlocks;
    dim3 blocks(1, 1, 1), threads(0, 0, 0);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_92_cuda_kernel_int_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_adi_92_cuda_kernel_int_regs,
        &threads, &stream, 0);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    blocksS[2] = ((boundsHigh[2] - boundsLow[2]) / loopSteps[2] + 1 + (threads.x - 1)) / threads.x;
    blocksS[1] = blocksS[2] * ((boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1 + (threads.y - 1)) / threads.y;
    blocksS[0] = blocksS[1] * ((boundsHigh[0] - boundsLow[0]) / loopSteps[0] + 1 + (threads.z - 1)) / threads.z;

    /* Reduction-related stuff */

    /* GPU execution */
    restBlocks = blocksS[0];
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_adi_92_cuda_kernel<<<blocks, threads, 0, stream>>>(a_gen_0, a_gen_0_devHdr_gen_0[1], a_gen_0_devHdr_gen_0[2], a_gen_0_devHdr_gen_0[3], boundsLow[0], boundsHigh[0], loopSteps[0], boundsLow[1], boundsHigh[1], loopSteps[1], blocksS[1], boundsLow[2], boundsHigh[2], loopSteps[2], blocksS[2], blocksS[0] - restBlocks);
        restBlocks -= blocks.x;
    }
}
