/* DVMH includes */
#include <dvmhlib2.h>
#include <dvmlib.h>

/* Supplementary macros */
#define DVM0C(n) ((DvmType)(n))
#define DVM0C0 DVM0C(0)
#define DVM0C1 DVM0C(1)
#define DVM0C2 DVM0C(2)
#define DVM0C3 DVM0C(3)
#ifdef _OPENMP
    #define OMP_H_TYPE (HANDLER_TYPE_MASTER | HANDLER_TYPE_PARALLEL)
#else
    #define OMP_H_TYPE 0
#endif

/* Supplementary variables */
static DvmType cur_region = 0;
static DvmType cur_loop = 0;

/* Forward declarations for all files. Placed only in file with main. */
void initCdvmhGlobals_adi();

/* Rest of file, converted */
/* ADI program */

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

#define Max(a, b) ((a) > (b) ? (a) : (b))

#define nx 384
#define ny 384
#define nz 384

void init(DvmType a[]);

int main(int argc, char *argv[])
{
    dvmh_line_C(16, "../cdv-fdv-src/adi.cdv");
#ifdef _OPENMP
    dvmh_init_C(INITFLAG_OPENMP, &argc, &argv);
#else
    dvmh_init_C(0, &argc, &argv);
#endif

    /* Call to all such functions */
    initCdvmhGlobals_adi();

    double maxeps, eps;
    DvmType a[12] /*array, rank=3, baseType=double*/;
    dvmh_line_C(19, "../cdv-fdv-src/adi.cdv");
    dvmh_array_declare_C(a, 3, -rt_DOUBLE, DVM0C0, DVM0C1, DVM0C1, DVM0C(384), DVM0C1, DVM0C1, DVM0C(384), DVM0C1, DVM0C1);
    int it, itmax, i, j, k;
    double startt, endt;
    maxeps = 0.01;
    itmax = 100;
    dvmh_line_C(25, "../cdv-fdv-src/adi.cdv");
    dvmh_array_alloc_C(a, (nx * ny * nz * sizeof(double)));
    dvmh_distribute_C(a, DVM0C1, DVM0C1, DVM0C1);
    init(a);

#ifdef _DVMH
    dvmh_barrier();
    startt = dvmh_wtime();
#else
    startt = 0;
#endif
    for (it = 1; it <= itmax; it++)
    {
        eps = 0;
        dvmh_line_C(37, "../cdv-fdv-src/adi.cdv");
        dvmh_actual_variable2_((const void *)&eps);

        {
            dvmh_line_C(38, "../cdv-fdv-src/adi.cdv");
            cur_region = dvmh_region_create_C(0);
            dvmh_region_register_array_C(cur_region, INTENT_IN | INTENT_OUT, a, "a");
            dvmh_region_execute_on_targets_C(cur_region, DEVICE_TYPE_HOST | DEVICE_TYPE_CUDA);

        dvmh_line_C(40, "../cdv-fdv-src/adi.cdv");
            /* Loop's mandatory characteristics */
            cur_loop = dvmh_loop_create_C(cur_region, 3, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1);
            dvmh_loop_map_C(cur_loop, a, DVM0C1, DVM0C1, DVM0C0, DVM0C2, DVM0C1, DVM0C0, DVM0C3, DVM0C1, DVM0C0);
            /* Optional clauses */
            dvmh_loop_across_C(cur_loop, a, DVM0C1, DVM0C1, DVM0C0, DVM0C0, DVM0C0, DVM0C0);
            /* Register handlers */
            void loop_adi_41_host(DvmType *, DvmType []);
            dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_HOST, OMP_H_TYPE, (GenFunc)loop_adi_41_host, 1, a);
            void loop_adi_41_cuda(DvmType *, DvmType []);
            dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_CUDA, 0, (GenFunc)loop_adi_41_cuda, 1, a);

            dvmh_line_C(41, "../cdv-fdv-src/adi.cdv");
            dvmh_loop_perform_C(cur_loop);
            cur_loop = 0;
        dvmh_line_C(45, "../cdv-fdv-src/adi.cdv");
            /* Loop's mandatory characteristics */
            cur_loop = dvmh_loop_create_C(cur_region, 3, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1);
            dvmh_loop_map_C(cur_loop, a, DVM0C1, DVM0C1, DVM0C0, DVM0C2, DVM0C1, DVM0C0, DVM0C3, DVM0C1, DVM0C0);
            /* Optional clauses */
            dvmh_loop_across_C(cur_loop, a, DVM0C0, DVM0C0, DVM0C1, DVM0C1, DVM0C0, DVM0C0);
            /* Register handlers */
            void loop_adi_46_host(DvmType *, DvmType []);
            dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_HOST, OMP_H_TYPE, (GenFunc)loop_adi_46_host, 1, a);
            void loop_adi_46_cuda(DvmType *, DvmType []);
            dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_CUDA, 0, (GenFunc)loop_adi_46_cuda, 1, a);

            dvmh_line_C(46, "../cdv-fdv-src/adi.cdv");
            dvmh_loop_perform_C(cur_loop);
            cur_loop = 0;
        dvmh_line_C(50, "../cdv-fdv-src/adi.cdv");
            /* Loop's mandatory characteristics */
            cur_loop = dvmh_loop_create_C(cur_region, 3, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1, DVM0C1, DVM0C((384 - 1) - 1), DVM0C1);
            dvmh_loop_map_C(cur_loop, a, DVM0C1, DVM0C1, DVM0C0, DVM0C2, DVM0C1, DVM0C0, DVM0C3, DVM0C1, DVM0C0);
            /* Optional clauses */
            dvmh_loop_across_C(cur_loop, a, DVM0C0, DVM0C0, DVM0C0, DVM0C0, DVM0C1, DVM0C1);
            dvmh_loop_reduction_C(cur_loop, rf_MAX, &eps, rt_DOUBLE, 1, 0, 0);
            /* Register handlers */
            void loop_adi_51_host(DvmType *, DvmType []);
            dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_HOST, OMP_H_TYPE, (GenFunc)loop_adi_51_host, 1, a);
            void loop_adi_51_cuda(DvmType *, DvmType []);
            dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_CUDA, 0, (GenFunc)loop_adi_51_cuda, 1, a);

            dvmh_line_C(51, "../cdv-fdv-src/adi.cdv");
            dvmh_loop_perform_C(cur_loop);
            cur_loop = 0;

        
            dvmh_line_C(60, "../cdv-fdv-src/adi.cdv");
            dvmh_region_end_C(cur_region);
            cur_region = 0;
        }
        dvmh_line_C(61, "../cdv-fdv-src/adi.cdv");
        dvmh_get_actual_variable2_((void *)&eps);

        dvm_printf(" IT = %4i   EPS = %14.7E\n", it, eps);
        if (eps < maxeps)
            break;
    }
#ifdef _DVMH
    dvmh_barrier();
    endt = dvmh_wtime();
#else
    endt = 0;
#endif
    dvmh_line_C(72, "../cdv-fdv-src/adi.cdv");
    dvmh_array_free_C(a);

    dvm_printf(" ADI Benchmark Completed.\n");
    dvm_printf(" Size            = %4d x %4d x %4d\n", nx, ny, nz);
    dvm_printf(" Iterations      =       %12d\n", itmax);
    dvm_printf(" Time in seconds =       %12.2lf\n", endt - startt);
    dvm_printf(" Operation type  =   double precision\n");
    dvm_printf(" Verification    =       %12s\n", (fabs(eps - 0.07249074) < 1e-6 ? "SUCCESSFUL" : "UNSUCCESSFUL"));

    dvm_printf(" END OF ADI Benchmark\n");
    dvmh_line_C(82, "../cdv-fdv-src/adi.cdv");
    dvmh_forget_header_(a);
    dvmh_exit_C( 0);

    dvmh_line_C(83, "../cdv-fdv-src/adi.cdv");
    dvmh_forget_header_(a);
    dvmh_exit_C(0);
}

void init(DvmType a[])
{
    int i, j, k;
    {
        dvmh_line_C(89, "../cdv-fdv-src/adi.cdv");
        cur_region = dvmh_region_create_C(0);
        dvmh_region_register_array_C(cur_region, INTENT_OUT, a, "a");
        dvmh_region_execute_on_targets_C(cur_region, DEVICE_TYPE_HOST | DEVICE_TYPE_CUDA);

    dvmh_line_C(91, "../cdv-fdv-src/adi.cdv");
        /* Loop's mandatory characteristics */
        cur_loop = dvmh_loop_create_C(cur_region, 3, DVM0C0, DVM0C((384) - 1), DVM0C1, DVM0C0, DVM0C((384) - 1), DVM0C1, DVM0C0, DVM0C((384) - 1), DVM0C1);
        dvmh_loop_map_C(cur_loop, a, DVM0C1, DVM0C1, DVM0C0, DVM0C2, DVM0C1, DVM0C0, DVM0C3, DVM0C1, DVM0C0);
        /* Register handlers */
        void loop_adi_92_host(DvmType *, DvmType []);
        dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_HOST, OMP_H_TYPE, (GenFunc)loop_adi_92_host, 1, a);
        void loop_adi_92_cuda(DvmType *, DvmType []);
        dvmh_loop_register_handler_C(cur_loop, DEVICE_TYPE_CUDA, 0, (GenFunc)loop_adi_92_cuda, 1, a);

        dvmh_line_C(92, "../cdv-fdv-src/adi.cdv");
        dvmh_loop_perform_C(cur_loop);
        cur_loop = 0;
;
    
        dvmh_line_C(99, "../cdv-fdv-src/adi.cdv");
        dvmh_region_end_C(cur_region);
        cur_region = 0;
    }
}

void initCdvmhGlobals_adi() {
}

/* Host handlers placed in the same file, maybe they will be moved to separate file in future */
#ifdef _OPENMP
#include <omp.h>
#endif

void loop_adi_41_host(DvmType *pLoopRef, DvmType a_hdr[]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    double (*a)[a_hdr[1]/a_hdr[2]][a_hdr[2]] = dvmh_get_natural_base_C(device_num, a_hdr);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    int slotCount;
    DvmType dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
#ifdef _OPENMP
    int threadSync[slotCount];
#endif

#ifdef _OPENMP
    #pragma omp parallel num_threads(slotCount), private(i, j, k)
#endif
    {
#ifdef _OPENMP
        int currentThread = 0, workingThreads = slotCount;
#endif
        if (((dependencyMask >> 2) & 1) == 0) {
#ifdef _OPENMP
            #pragma omp for schedule(runtime), nowait
#endif
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i - 1][j][k] + a[i + 1][j][k]) / 2;
                    }
        } else if (((dependencyMask >> 1) & 1) == 0) {
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
#ifdef _OPENMP
                #pragma omp for schedule(runtime), nowait
#endif
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i - 1][j][k] + a[i + 1][j][k]) / 2;
                    }
        } else if (((dependencyMask >> 0) & 1) == 0) {
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
#ifdef _OPENMP
                    #pragma omp for schedule(runtime), nowait
#endif
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i - 1][j][k] + a[i + 1][j][k]) / 2;
                    }
        } else {
#ifdef _OPENMP
            if ((boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1 < workingThreads)
                workingThreads = (boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1;
            currentThread = omp_get_thread_num();
            threadSync[currentThread] = 0;
            #pragma omp barrier
#endif
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
            {
#ifdef _OPENMP
                if (currentThread > 0 && currentThread < workingThreads) {
                    do {
                        #pragma omp flush(threadSync)
                    } while (!threadSync[currentThread - 1]);
                    threadSync[currentThread - 1] = 0;
                    #pragma omp flush(threadSync)
                }
                #pragma omp for schedule(static), nowait
#endif
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i - 1][j][k] + a[i + 1][j][k]) / 2;
                    }
#ifdef _OPENMP
                if (currentThread < workingThreads - 1) {
                    do {
                        #pragma omp flush(threadSync)
                    } while (threadSync[currentThread]);
                    threadSync[currentThread] = 1;
                    #pragma omp flush(threadSync)
                }
#endif
            }
        }
    }
}

void loop_adi_46_host(DvmType *pLoopRef, DvmType a_hdr[]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    double (*a)[a_hdr[1]/a_hdr[2]][a_hdr[2]] = dvmh_get_natural_base_C(device_num, a_hdr);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    int slotCount;
    DvmType dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
#ifdef _OPENMP
    int threadSync[slotCount];
#endif

#ifdef _OPENMP
    #pragma omp parallel num_threads(slotCount), private(i, j, k)
#endif
    {
#ifdef _OPENMP
        int currentThread = 0, workingThreads = slotCount;
#endif
        if (((dependencyMask >> 2) & 1) == 0) {
#ifdef _OPENMP
            #pragma omp for schedule(runtime), nowait
#endif
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i][j - 1][k] + a[i][j + 1][k]) / 2;
                    }
        } else if (((dependencyMask >> 1) & 1) == 0) {
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
#ifdef _OPENMP
                #pragma omp for schedule(runtime), nowait
#endif
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i][j - 1][k] + a[i][j + 1][k]) / 2;
                    }
        } else if (((dependencyMask >> 0) & 1) == 0) {
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
#ifdef _OPENMP
                    #pragma omp for schedule(runtime), nowait
#endif
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i][j - 1][k] + a[i][j + 1][k]) / 2;
                    }
        } else {
#ifdef _OPENMP
            if ((boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1 < workingThreads)
                workingThreads = (boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1;
            currentThread = omp_get_thread_num();
            threadSync[currentThread] = 0;
            #pragma omp barrier
#endif
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
            {
#ifdef _OPENMP
                if (currentThread > 0 && currentThread < workingThreads) {
                    do {
                        #pragma omp flush(threadSync)
                    } while (!threadSync[currentThread - 1]);
                    threadSync[currentThread - 1] = 0;
                    #pragma omp flush(threadSync)
                }
                #pragma omp for schedule(static), nowait
#endif
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                        a[i][j][k] = (a[i][j - 1][k] + a[i][j + 1][k]) / 2;
                    }
#ifdef _OPENMP
                if (currentThread < workingThreads - 1) {
                    do {
                        #pragma omp flush(threadSync)
                    } while (threadSync[currentThread]);
                    threadSync[currentThread] = 1;
                    #pragma omp flush(threadSync)
                }
#endif
            }
        }
    }
}

void loop_adi_51_host(DvmType *pLoopRef, DvmType a_hdr[]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    double (*a)[a_hdr[1]/a_hdr[2]][a_hdr[2]] = dvmh_get_natural_base_C(device_num, a_hdr);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    int slotCount;
    DvmType dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;
    double eps;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
#ifdef _OPENMP
    int threadSync[slotCount];
#endif

#ifdef _OPENMP
    #pragma omp parallel num_threads(slotCount), private(i, j, k), private(eps)
#endif
    {
#ifdef _OPENMP
        int currentThread = 0, workingThreads = slotCount;
#endif
        dvmh_loop_red_init_C(loop_ref, 1, &eps, 0);
        if (((dependencyMask >> 2) & 1) == 0) {
#ifdef _OPENMP
            #pragma omp for schedule(runtime), nowait
#endif
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                      double tmp1 = (a[i][j][k - 1] + a[i][j][k + 1]) / 2;
                      double tmp2 = fabs(a[i][j][k] - tmp1);
                      eps = ((eps) > (tmp2) ? (eps) : (tmp2));
                      a[i][j][k] = tmp1;
                    }
        } else if (((dependencyMask >> 1) & 1) == 0) {
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
#ifdef _OPENMP
                #pragma omp for schedule(runtime), nowait
#endif
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                      double tmp1 = (a[i][j][k - 1] + a[i][j][k + 1]) / 2;
                      double tmp2 = fabs(a[i][j][k] - tmp1);
                      eps = ((eps) > (tmp2) ? (eps) : (tmp2));
                      a[i][j][k] = tmp1;
                    }
        } else if (((dependencyMask >> 0) & 1) == 0) {
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
#ifdef _OPENMP
                    #pragma omp for schedule(runtime), nowait
#endif
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                      double tmp1 = (a[i][j][k - 1] + a[i][j][k + 1]) / 2;
                      double tmp2 = fabs(a[i][j][k] - tmp1);
                      eps = ((eps) > (tmp2) ? (eps) : (tmp2));
                      a[i][j][k] = tmp1;
                    }
        } else {
#ifdef _OPENMP
            if ((boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1 < workingThreads)
                workingThreads = (boundsHigh[1] - boundsLow[1]) / loopSteps[1] + 1;
            currentThread = omp_get_thread_num();
            threadSync[currentThread] = 0;
            #pragma omp barrier
#endif
            for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
            {
#ifdef _OPENMP
                if (currentThread > 0 && currentThread < workingThreads) {
                    do {
                        #pragma omp flush(threadSync)
                    } while (!threadSync[currentThread - 1]);
                    threadSync[currentThread - 1] = 0;
                    #pragma omp flush(threadSync)
                }
                #pragma omp for schedule(static), nowait
#endif
                for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                    for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                    {
                      double tmp1 = (a[i][j][k - 1] + a[i][j][k + 1]) / 2;
                      double tmp2 = fabs(a[i][j][k] - tmp1);
                      eps = ((eps) > (tmp2) ? (eps) : (tmp2));
                      a[i][j][k] = tmp1;
                    }
#ifdef _OPENMP
                if (currentThread < workingThreads - 1) {
                    do {
                        #pragma omp flush(threadSync)
                    } while (threadSync[currentThread]);
                    threadSync[currentThread] = 1;
                    #pragma omp flush(threadSync)
                }
#endif
            }
        }
        dvmh_loop_red_post_C(loop_ref, 1, &eps, 0);
    }

}

void loop_adi_92_host(DvmType *pLoopRef, DvmType a_hdr[]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    double (*a)[a_hdr[1]/a_hdr[2]][a_hdr[2]] = dvmh_get_natural_base_C(device_num, a_hdr);
    /* Supplementary variables for loop handling */
    IndexType boundsLow[3], boundsHigh[3], loopSteps[3];
    int slotCount;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int k;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);

#ifdef _OPENMP
    #pragma omp parallel num_threads(slotCount), private(i, j, k)
#endif
    {
#ifdef _OPENMP
        #pragma omp for schedule(runtime), nowait
#endif
        for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
            for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
                for (k = boundsLow[2]; k <= boundsHigh[2]; k++)
                {
                    if (k == 0 || k == 384 - 1 || j == 0 || j == 384 - 1 || i == 0 || i == 384 - 1)
                      a[i][j][k] = 10. * i / (384 - 1) + 10. * j / (384 - 1) + 10. * k / (384 - 1);
                    else
                      a[i][j][k] = 0;
                }
    }
}

