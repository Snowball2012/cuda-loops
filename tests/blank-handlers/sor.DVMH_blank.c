static int DVMH_VARIABLE_ARRAY_SIZE = 0;

#pragma dvm handler_stub dvm_array(A), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1)), reduction(), private(), remote_access()
void loop_sor_28(float A[][10]) {
    int i;
    int j;

        {
            if (i == j)
              A[i][j] = 10 + 2;
            else
              A[i][j] = -1.F;
        }

}

#pragma dvm handler_stub dvm_array(A), regular_array(), scalar(w), loop_var(i(1, 1), j(1, 1)), reduction(max(eps)), private(), remote_access(), across()
void loop_sor_46(float A[][10], float w) {
    int i;
    int j;
    float eps;

        {
          float s;
          s = A[i][j];
          A[i][j] = (w / 4) * (A[i - 1][j] + A[i + 1][j] + A[i][j - 1] + A[i][j + 1]) + (1 - w) * A[i][j];
          eps = ((fabs(s - A[i][j])) > (eps) ? (fabs(s - A[i][j])) : (eps));
        }

}

