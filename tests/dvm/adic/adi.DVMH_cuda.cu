#include <cassert>

/* DVMH includes */
#include <dvmhlib2.h>
#include <dvmh_cuda_helpers.h>
#include <curand_mtgp32_kernel.h>

int where_dep(int *ret, int n, DvmType type_of_run, DvmType *idxs, int dep) {
    int count = 0;
    int h = 0;
    int hd = dep;
    for (int i = 0; i < n; ++i) {
        ret[i] = 0;
        if (type_of_run % 2 != 0) {
            ret[i] = 1;
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

void change_filled_bounds(DvmType *low, DvmType *high, DvmType *idx, DvmType n, DvmType dep, DvmType type_of_run, DvmType *idxs) {

    int p[n];

    int where_ = where_dep(p, n, type_of_run, idxs, dep);

    bool cond = true;
    for (int i = 0; i < dep; i++)
        cond = cond && (p[i] == 1);
    if (cond) {
        // Nothing to do in that case
        return;
    }

    int depIdxs[n], inDepIdxs[n];
    DvmType tmpI[n], tmpH[n], tmpL[n];

    int depIdxsLen = 0, inDepIdxsLen = 0;
    for (int i = 0; i < n; ++i) {
        if (p[n - 1 - i] == 1)
            depIdxs[depIdxsLen++] = i;
        else
            inDepIdxs[inDepIdxsLen++] = i;
    }

    int count = 0;
    for (int i = 0; i < inDepIdxsLen; i++) {
        tmpI[count] = idx[inDepIdxs[i]];
        tmpL[count] = low[inDepIdxs[i]];
        tmpH[count] = high[inDepIdxs[i]];
        count++;
    }
    for (int i = 0; i < depIdxsLen; i++) {
        tmpI[count] = idx[depIdxs[i]];
        tmpL[count] = low[depIdxs[i]];
        tmpH[count] = high[depIdxs[i]];
        count++;
    }
    for (int i = 0; i < n; i++) {
        idx[i] = tmpI[i];
        low[i] = tmpL[i];
        high[i] = tmpH[i];
    }
}

__global__ void loop_adi_41_cuda_kernel(double *a, CudaIndexType a_hdr3, CudaIndexType a_hdr2, CudaIndexType a_hdr1, CudaIndexType num_elem_j, CudaIndexType num_elem_k, CudaIndexType base_i, CudaIndexType base_j, CudaIndexType base_k, CudaIndexType step_i, CudaIndexType step_j, CudaIndexType step_k, CudaIndexType idxs_0, CudaIndexType idxs_1, CudaIndexType idxs_2) {

    CudaIndexType id_x, id_y;
    CudaIndexType coords[3];

    int i;
    int j;
    int k;

    id_x = blockIdx.x * blockDim.x + threadIdx.x;
    id_y = blockIdx.y * blockDim.y + threadIdx.y;

    if (id_x < num_elem_j && id_y < num_elem_k) {
        coords[idxs_0] = base_i;
        coords[idxs_1] = base_j + id_x * step_j;
        coords[idxs_2] = base_k + id_y * step_k;
        i = coords[0];
        j = coords[1];
        k = coords[2];


            a[i * a_hdr3 + j * a_hdr2 + k * a_hdr1] = (a[(i - 1) * a_hdr3 + j * a_hdr2 + k * a_hdr1] + a[(i + 1) * a_hdr3 + j * a_hdr2 + k * a_hdr1]) / 2;

    }
}

extern "C" void loop_adi_41_cuda_across(DvmType *pLoopRef, DvmType a_hdr[], int dep_mask) {
    DvmType tmpVar;

    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);

    dvmh_loop_autotransform_C(loop_ref, a_hdr);
    double *a = (double *)dvmh_get_natural_base_C(device_num, a_hdr);
    DvmType a_devHdr[6];
    tmpVar = dvmh_fill_header_C(device_num, a, a_hdr, a_devHdr, 0);
    assert(tmpVar == 0 || tmpVar == 1);

    IndexType boundsLow[3], boundsHigh[3], loopSteps[3], idxs[3];
    CudaIndexType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_41_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_adi_41_cuda_kernel_regs, &threads, &stream, 0);


    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    change_filled_bounds(boundsLow, boundsHigh, loopSteps, 3, 1, dep_mask, idxs);


    int num_elem_x = (abs(boundsLow[1] - boundsHigh[1]) + 1) / abs(loopSteps[1]) + ((abs(boundsLow[1] - boundsHigh[1]) + 1) % abs(loopSteps[1]) != 0);
    int num_elem_y = (abs(boundsLow[0] - boundsHigh[0]) + 1) / abs(loopSteps[0]) + ((abs(boundsLow[0] - boundsHigh[0]) + 1) % abs(loopSteps[0]) != 0);

    int base_i = boundsLow[2];
    int base_j = boundsLow[1];
    int base_k = boundsLow[0];

    blocks.x = num_elem_x / threads.x + ((num_elem_x % threads.x != 0)?1:0);
    blocks.y = num_elem_y / threads.y + ((num_elem_y % threads.y != 0)?1:0);
    boundsHigh[2] = (abs(boundsHigh[2] - boundsLow[2]) + 1) / abs(loopSteps[2]);

    for (int tmpV = 0; tmpV < boundsHigh[2]; base_i += loopSteps[2], tmpV++) {
        loop_adi_41_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[3], a_devHdr[2], a_devHdr[1], num_elem_x, num_elem_y, base_i, base_j, base_k, loopSteps[2], loopSteps[1], loopSteps[0], idxs[0], idxs[1], idxs[2]);
    }
}

extern "C" void loop_adi_41_cuda(DvmType *pLoopRef, DvmType a_hdr[]) {
    int dep_mask = dvmh_loop_get_dependency_mask_C(*pLoopRef);

    if (dep_mask == 1 || dep_mask == 2 || dep_mask == 4) {
        loop_adi_41_cuda_across(pLoopRef, a_hdr, dep_mask);
    }
}

__global__ void loop_adi_46_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType a_hdr3, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3) {
    /* Parameters */
    DvmhPermutatedArrayHelper3<double> a(a_base, a_hdr1, a_hdr2, a_hdr3);
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    for (i = boundsLow_1; i <= boundsHigh_1; i++)
        for (j = boundsLow_2; j <= boundsHigh_2; j++)
            for (k = boundsLow_3; k <= boundsHigh_3; k++)
            {
                a[i][j][k] = (a[i][j - 1][k] + a[i][j + 1][k]) / 2;
            }
}

extern "C" void loop_adi_46_cuda(DvmType *pLoopRef, DvmType a_hdr[]) {
    DvmType tmpVar;
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    dvmh_loop_autotransform_C(loop_ref, a_hdr);
    double *a = (double *)dvmh_get_natural_base_C(device_num, a_hdr);
    DvmType a_devHdr[6];
    tmpVar = dvmh_fill_header_C(device_num, a, a_hdr, a_devHdr, 0);
    assert(tmpVar == 0 || tmpVar == 1);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    CudaIndexType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_46_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_adi_46_cuda_kernel_regs, &threads, &stream, 0);
    threads = dim3(1, 1, 1);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);

    /* GPU execution */
    restBlocks = 1;
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_adi_46_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], a_devHdr[3], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], boundsLow[2], boundsHigh[2]);
        restBlocks -= blocks.x;
    }
}

__global__ void loop_adi_51_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType a_hdr3, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3, double eps, double eps_grid[]) {
    /* Parameters */
    DvmhPermutatedArrayHelper3<double> a(a_base, a_hdr1, a_hdr2, a_hdr3);
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    for (i = boundsLow_1; i <= boundsHigh_1; i++)
        for (j = boundsLow_2; j <= boundsHigh_2; j++)
            for (k = boundsLow_3; k <= boundsHigh_3; k++)
            {
              double tmp1 = (a[i][j][k - 1] + a[i][j][k + 1]) / 2;
              double tmp2 = fabs(a[i][j][k] - tmp1);
              eps = ((eps) > (tmp2) ? (eps) : (tmp2));
              a[i][j][k] = tmp1;
            }

    /* Write reduction values to global memory */
    eps_grid[0] = eps;
}

extern "C" void loop_adi_51_cuda(DvmType *pLoopRef, DvmType a_hdr[]) {
    DvmType tmpVar;
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    dvmh_loop_autotransform_C(loop_ref, a_hdr);
    double *a = (double *)dvmh_get_natural_base_C(device_num, a_hdr);
    DvmType a_devHdr[6];
    tmpVar = dvmh_fill_header_C(device_num, a, a_hdr, a_devHdr, 0);
    assert(tmpVar == 0 || tmpVar == 1);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    CudaIndexType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_51_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_adi_51_cuda_kernel_regs, &threads, &stream, 0);
    threads = dim3(1, 1, 1);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);

    /* Reductions-related stuff */
    double eps;
    double *eps_grid;
    dvmh_loop_cuda_register_red_C(loop_ref, 1, (void **)&eps_grid, 0);
    dvmh_loop_red_init_C(loop_ref, 1, &eps, 0);
    dvmh_loop_cuda_red_prepare_C(loop_ref, 1, 1, 0);

    /* GPU execution */
    restBlocks = 1;
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_adi_51_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], a_devHdr[3], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], boundsLow[2], boundsHigh[2], eps, eps_grid);
        restBlocks -= blocks.x;
    }

    dvmh_loop_cuda_red_finish_C(loop_ref, 1);
}

__global__ void loop_adi_92_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType a_hdr3, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType blocksS_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3, CudaIndexType blocksS_3, CudaIndexType blockOffset) {
    /* Parameters */
    DvmhPermutatedArrayHelper3<double> a(a_base, a_hdr1, a_hdr2, a_hdr3);
    /* Supplementary variables for loop handling */
    CudaIndexType restBlocks, curBlocks;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    restBlocks = blockIdx.x + blockOffset;
    curBlocks = restBlocks / blocksS_2;
    i = boundsLow_1 + (curBlocks * blockDim.z + threadIdx.z);
    if (i <= boundsHigh_1) {
        restBlocks = restBlocks - curBlocks * blocksS_2;
        curBlocks = restBlocks / blocksS_3;
        j = boundsLow_2 + (curBlocks * blockDim.y + threadIdx.y);
        if (j <= boundsHigh_2) {
            restBlocks = restBlocks - curBlocks * blocksS_3;
            curBlocks = restBlocks;
            k = boundsLow_3 + (curBlocks * blockDim.x + threadIdx.x);
            if (k <= boundsHigh_3)
            {
                if (k == 0 || k == 384 - 1 || j == 0 || j == 384 - 1 || i == 0 || i == 384 - 1)
                  a[i][j][k] = 10. * i / (384 - 1) + 10. * j / (384 - 1) + 10. * k / (384 - 1);
                else
                  a[i][j][k] = 0;
            }
        }
    }
}

extern "C" void loop_adi_92_cuda(DvmType *pLoopRef, DvmType a_hdr[]) {
    DvmType tmpVar;
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    dvmh_loop_autotransform_C(loop_ref, a_hdr);
    double *a = (double *)dvmh_get_natural_base_C(device_num, a_hdr);
    DvmType a_devHdr[6];
    tmpVar = dvmh_fill_header_C(device_num, a, a_hdr, a_devHdr, 0);
    assert(tmpVar == 0 || tmpVar == 1);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    CudaIndexType blocksS[3];
    CudaIndexType restBlocks;
    dim3 blocks(1, 1, 1), threads(0, 0, 0);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_adi_92_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_adi_92_cuda_kernel_regs, &threads, &stream, 0);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    blocksS[2] = ((boundsHigh[2] - boundsLow[2]) / loopSteps[2] + 1 + (threads.x - 1)) / threads.x;
    blocksS[1] = blocksS[2] * (((boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1 + (threads.y - 1)) / threads.y);
    blocksS[0] = blocksS[1] * (((boundsHigh[0] - boundsLow[0]) / loopSteps[0] + 1 + (threads.z - 1)) / threads.z);

    /* GPU execution */
    restBlocks = blocksS[0];
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_adi_92_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], a_devHdr[3], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], blocksS[1], boundsLow[2], boundsHigh[2], blocksS[2], blocksS[0] - restBlocks);
        restBlocks -= blocks.x;
    }
}

