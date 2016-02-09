#include <cassert>

/* DVMH includes */
#include <dvmhlib2.h>
#include <dvmh_cuda_helpers.h>
#include <cuda_runtime.h>

__global__ void loop_adi_41_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3) {
    /* Parameters */
    DvmhArrayHelper3<double> a(a_base, a_hdr1, a_hdr2);
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    for (i = boundsLow_1; i <= boundsHigh_1; i++)
        for (j = boundsLow_2; j <= boundsHigh_2; j++)
            for (k = boundsLow_3; k <= boundsHigh_3; k++)
            {
                a[i][j][k] = (a[i - 1][j][k] + a[i + 1][j][k]) / 2;
            }
}




extern "C" void loop_adi_41_cuda(DvmType *pLoopRef, DvmType a_hdr[]) {
    DvmType tmpVar;
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
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
    extern DvmType loop_adi_41_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_adi_41_cuda_kernel_regs, &threads, &stream, 0);
    threads = dim3(1, 1, 1);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);

    /* GPU execution */
    restBlocks = 1;
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_adi_41_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], boundsLow[2], boundsHigh[2]);
        restBlocks -= blocks.x;
    }
}

__global__ void loop_adi_46_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3) {
    /* Parameters */
    DvmhArrayHelper3<double> a(a_base, a_hdr1, a_hdr2);
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
        loop_adi_46_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], boundsLow[2], boundsHigh[2]);
        restBlocks -= blocks.x;
    }
}

__global__ void loop_adi_51_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3, double eps, double eps_grid[]) {
    /* Parameters */
    DvmhArrayHelper3<double> a(a_base, a_hdr1, a_hdr2);
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
        loop_adi_51_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], boundsLow[2], boundsHigh[2], eps, eps_grid);
        restBlocks -= blocks.x;
    }

    dvmh_loop_cuda_red_finish_C(loop_ref, 1);
}

__global__ void loop_adi_92_cuda_kernel(double *a_base, CudaIndexType a_hdr1, CudaIndexType a_hdr2, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType blocksS_2, CudaIndexType boundsLow_3, CudaIndexType boundsHigh_3, CudaIndexType blocksS_3, CudaIndexType blockOffset) {
    /* Parameters */
    DvmhArrayHelper3<double> a(a_base, a_hdr1, a_hdr2);
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
        loop_adi_92_cuda_kernel<<<blocks, threads, 0, stream>>>(a, a_devHdr[1], a_devHdr[2], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], blocksS[1], boundsLow[2], boundsHigh[2], blocksS[2], blocksS[0] - restBlocks);
        restBlocks -= blocks.x;
    }
}

