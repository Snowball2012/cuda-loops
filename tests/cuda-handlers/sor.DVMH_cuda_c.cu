#include <cassert>

/* DVMH includes */
#include <dvmhlib2.h>
#include <dvmh_cuda_helpers.h>

__global__ void loop_sor_28_cuda_kernel(float *A_base, CudaIndexType A_hdr1, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, CudaIndexType blocksS_2, CudaIndexType blockOffset) {
    /* Parameters */
    DvmhArrayHelper2<float> A(A_base, A_hdr1);
    /* Supplementary variables for loop handling */
    CudaIndexType restBlocks, curBlocks;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;

    restBlocks = blockIdx.x + blockOffset;
    curBlocks = restBlocks / blocksS_2;
    i = boundsLow_1 + (curBlocks * blockDim.y + threadIdx.y);
    if (i <= boundsHigh_1) {
        restBlocks = restBlocks - curBlocks * blocksS_2;
        curBlocks = restBlocks;
        j = boundsLow_2 + (curBlocks * blockDim.x + threadIdx.x);
        if (j <= boundsHigh_2)
        {
            if (i == j)
              A[i][j] = 10 + 2;
            else
              A[i][j] = -1.F;
        }
    }
}

extern "C" void loop_sor_28_cuda(DvmType *pLoopRef, DvmType A_hdr[]) {
    DvmType tmpVar;
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    float *A = (float *)dvmh_get_natural_base_C(device_num, A_hdr);
    DvmType A_devHdr[5];
    tmpVar = dvmh_fill_header_C(device_num, A, A_hdr, A_devHdr, 0);
    assert(tmpVar == 0 || tmpVar == 1);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[2], boundsHigh[2], loopSteps[2];
    CudaIndexType blocksS[2];
    CudaIndexType restBlocks;
    dim3 blocks(1, 1, 1), threads(0, 0, 0);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_sor_28_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_sor_28_cuda_kernel_regs, &threads, &stream, 0);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    blocksS[1] = ((boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1 + (threads.x - 1)) / threads.x;
    blocksS[0] = blocksS[1] * (((boundsHigh[0] - boundsLow[0]) / loopSteps[0] + 1 + (threads.y - 1)) / threads.y);

    /* GPU execution */
    restBlocks = blocksS[0];
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_sor_28_cuda_kernel<<<blocks, threads, 0, stream>>>(A, A_devHdr[1], boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], blocksS[1], blocksS[0] - restBlocks);
        restBlocks -= blocks.x;
    }
}

__global__ void loop_sor_46_cuda_kernel(float *A_base, CudaIndexType A_hdr1, float *w_ptr, CudaIndexType boundsLow_1, CudaIndexType boundsHigh_1, CudaIndexType boundsLow_2, CudaIndexType boundsHigh_2, float eps, float eps_grid[]) {
    /* Parameters */
    DvmhArrayHelper2<float> A(A_base, A_hdr1);
    float &w = *w_ptr;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;

    for (i = boundsLow_1; i <= boundsHigh_1; i++)
        for (j = boundsLow_2; j <= boundsHigh_2; j++)
        {
          float s;
          s = A[i][j];
          A[i][j] = (w / 4) * (A[i - 1][j] + A[i + 1][j] + A[i][j - 1] + A[i][j + 1]) + (1 - w) * A[i][j];
          eps = ((fabs(s - A[i][j])) > (eps) ? (fabs(s - A[i][j])) : (eps));
        }

    /* Write reduction values to global memory */
    eps_grid[0] = eps;
}

extern "C" void loop_sor_46_cuda(DvmType *pLoopRef, DvmType A_hdr[], float *w_ptr) {
    DvmType tmpVar;
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    float *A = (float *)dvmh_get_natural_base_C(device_num, A_hdr);
    DvmType A_devHdr[5];
    tmpVar = dvmh_fill_header_C(device_num, A, A_hdr, A_devHdr, 0);
    assert(tmpVar == 0 || tmpVar == 1);
    float *w = (float *)dvmh_get_device_addr_C(device_num, w_ptr);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[2], boundsHigh[2], loopSteps[2];
    CudaIndexType restBlocks;
    dim3 blocks(1, 1, 1), threads(1, 1, 1);
    cudaStream_t stream;

    /* Get CUDA configuration parameters */
    extern DvmType loop_sor_46_cuda_kernel_regs;
    dvmh_loop_cuda_get_config_C(loop_ref, 0, loop_sor_46_cuda_kernel_regs, &threads, &stream, 0);
    threads = dim3(1, 1, 1);

    /* Calculate computation distribution parameters */
    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);

    /* Reductions-related stuff */
    float eps;
    float *eps_grid;
    dvmh_loop_cuda_register_red_C(loop_ref, 1, (void **)&eps_grid, 0);
    dvmh_loop_red_init_C(loop_ref, 1, &eps, 0);
    dvmh_loop_cuda_red_prepare_C(loop_ref, 1, 1, 0);

    /* GPU execution */
    restBlocks = 1;
    while (restBlocks > 0) {
        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));
        loop_sor_46_cuda_kernel<<<blocks, threads, 0, stream>>>(A, A_devHdr[1], w, boundsLow[0], boundsHigh[0], boundsLow[1], boundsHigh[1], eps, eps_grid);
        restBlocks -= blocks.x;
    }

    dvmh_loop_cuda_red_finish_C(loop_ref, 1);
}

