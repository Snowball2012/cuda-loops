/* DVMH include */
#include <dvmhlib2.h>

#pragma dvm inherit(A)
void loop_sor_28(DvmType *pLoopRef, float (*A)[10]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[2], boundsHigh[2], loopSteps[2];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
            if (i == j)
                A[i][j] = 10 + 2;
            else
                A[i][j] = -1.F;;
}

#pragma dvm inherit(A)
void loop_sor_46(DvmType *pLoopRef, float (*A)[10], float *w_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    float w = *w_ptr;
    /* Supplementary variables for loop handling */
    IndexType boundsLow[2], boundsHigh[2], loopSteps[2];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    float eps;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &eps, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
        {
            float s;
            s = A[i][j];
            A[i][j] = (w / 4) * (A[i - 1][j] + A[i + 1][j] + A[i][j - 1] + A[i][j + 1]) + (1 - w) * A[i][j];
            eps = ((fabs(s - A[i][j])) > (eps) ? (fabs(s - A[i][j])) : (eps));
        }

    dvmh_loop_red_post_C(loop_ref, 1, &eps, 0);
}

