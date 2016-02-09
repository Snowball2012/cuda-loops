/* DVMH include */
#include <dvmhlib2.h>

#pragma dvm inherit(B1)
void loop_align21_59(DvmType *pLoopRef, int B1[4]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        B1[i] = 0;
}

#pragma dvm inherit(A2, B1)
void loop_align21_62(DvmType *pLoopRef, int A2[8][8], int B1[4], int *NL_ptr, int *ib_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    int NL = *NL_ptr;
    int ib = *ib_ptr;
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
        {
            A2[i][j] = i * NL + j;
            if ((i == 1) && (j < 4)) {
                ib = j;
                B1[ib] = ib;
            }
        }
}

#pragma dvm inherit(A2, B1)
void loop_align21_73(DvmType *pLoopRef, int A2[8][8], int B1[4], int *NL_ptr, int *ia_ptr, int *j_ptr, int *ja_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    int NL = *NL_ptr;
    int ia = *ia_ptr;
    int j = *j_ptr;
    int ja = *ja_ptr;
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int erri;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &erri, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
    {
        if (B1[i] != i)
            if (erri > i)
                erri = i;
        ia = 1;
        ja = i;
        if (A2[ia][ja] != (ia * NL + ja))
            if (erri > i * NL / 10 + j)
                erri = i * NL / 10 + j;
    }

    dvmh_loop_red_post_C(loop_ref, 1, &erri, 0);
}

#pragma dvm inherit(B1)
void loop_align21_111(DvmType *pLoopRef, int B1[6]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        B1[i] = 0;
}

#pragma dvm inherit(A2, B1)
void loop_align21_114(DvmType *pLoopRef, int A2[14][3], int B1[6], int *NL_ptr, int *ib_ptr, int *k1i_ptr, int *li_ptr, int *lj_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    int NL = *NL_ptr;
    int ib = *ib_ptr;
    int k1i = *k1i_ptr;
    int li = *li_ptr;
    int lj = *lj_ptr;
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
        {
            A2[i][j] = i * NL + j;
            if (j == lj) {
                if (((i - li) == (((i - li) / k1i) * k1i)) && (((i - li) / k1i) >= 0) && (((i - li) / k1i) < 6)) {
                    ib = (i - li) / k1i;
                    B1[ib] = ib;
                }
            }
        }
}

#pragma dvm inherit(A2, B1)
void loop_align21_129(DvmType *pLoopRef, int A2[14][3], int B1[6], int *NL_ptr, int *ia_ptr, int *j_ptr, int *ja_ptr, int *k1i_ptr, int *li_ptr, int *lj_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    int NL = *NL_ptr;
    int ia = *ia_ptr;
    int j = *j_ptr;
    int ja = *ja_ptr;
    int k1i = *k1i_ptr;
    int li = *li_ptr;
    int lj = *lj_ptr;
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int erri;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &erri, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
    {
        if (B1[i] != i)
            if (erri > i)
                erri = i;
        ia = k1i * i + li;
        ja = lj;
        if (A2[ia][ja] != (ia * NL + ja))
            if (erri > i * NL / 10 + j)
                erri = i * NL / 10 + j;
    }

    dvmh_loop_red_post_C(loop_ref, 1, &erri, 0);
}

#pragma dvm inherit(B1)
void loop_align21_166(DvmType *pLoopRef, int B1[6]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        B1[i] = i;
}

#pragma dvm inherit(A2, B1)
void loop_align21_169(DvmType *pLoopRef, int A2[8][8], int B1[6], int *NL_ptr, int *ib_ptr, int *k1j_ptr, int *lj_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    int NL = *NL_ptr;
    int ib = *ib_ptr;
    int k1j = *k1j_ptr;
    int lj = *lj_ptr;
    /* Supplementary variables for loop handling */
    IndexType boundsLow[2], boundsHigh[2], loopSteps[2];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int erri;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &erri, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
        {
            A2[i][j] = i * NL + j;
            if (((j - lj) == (((j - lj) / k1j) * k1j)) && (((j - lj) / k1j) >= 0) && (((j - lj) / k1j) < 6)) {
                ib = (j - lj) / k1j;
                if (B1[ib] != ib)
                    if (erri > ib)
                        erri = ib;
            }
        }

    dvmh_loop_red_post_C(loop_ref, 1, &erri, 0);
}

#pragma dvm inherit(B1)
void loop_align21_184(DvmType *pLoopRef, int B1[6]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int s;
    int erri;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &erri, 0);
    dvmh_loop_red_init_C(loop_ref, 2, &s, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
    {
        s = s + B1[i];
        if (B1[i] != i)
            if (erri > i)
                erri = i;
    }

    dvmh_loop_red_post_C(loop_ref, 1, &erri, 0);
    dvmh_loop_red_post_C(loop_ref, 2, &s, 0);
}

#pragma dvm inherit(B1)
void loop_align21_223(DvmType *pLoopRef, int B1[5]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        B1[i] = i;
}

#pragma dvm inherit(A2, B1)
void loop_align21_226(DvmType *pLoopRef, int A2[28][8], int B1[5], int *NL_ptr, int *ib_ptr, int *k1i_ptr, int *li_ptr) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    int NL = *NL_ptr;
    int ib = *ib_ptr;
    int k1i = *k1i_ptr;
    int li = *li_ptr;
    /* Supplementary variables for loop handling */
    IndexType boundsLow[2], boundsHigh[2], loopSteps[2];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int j;
    int erri;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &erri, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        for (j = boundsLow[1]; j <= boundsHigh[1]; j++)
        {
            A2[i][j] = i * NL + j;
            if (((i - li) == (((i - li) / k1i) * k1i)) && (((i - li) / k1i) >= 0) && (((i - li) / k1i) < 5)) {
                ib = (i - li) / k1i;
                if (B1[ib] != ib)
                    if (erri > i)
                        erri = i;
            }
        }

    dvmh_loop_red_post_C(loop_ref, 1, &erri, 0);
}

#pragma dvm inherit(B1)
void loop_align21_241(DvmType *pLoopRef, int B1[5]) {
    /* Loop reference and device number */
    DvmType loop_ref = *pLoopRef;
    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);
    /* Parameters */
    /* Supplementary variables for loop handling */
    IndexType boundsLow[1], boundsHigh[1], loopSteps[1];
    DvmType slotCount, dependencyMask;
    /* User variables - loop index variables and other private variables */
    int i;
    int s;

    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);
    slotCount = dvmh_loop_get_slot_count_C(loop_ref);
    dependencyMask = dvmh_loop_get_dependency_mask_C(loop_ref);
    dvmh_loop_red_init_C(loop_ref, 1, &s, 0);

    for (i = boundsLow[0]; i <= boundsHigh[0]; i++)
        s = s + B1[i];

    dvmh_loop_red_post_C(loop_ref, 1, &s, 0);
}

