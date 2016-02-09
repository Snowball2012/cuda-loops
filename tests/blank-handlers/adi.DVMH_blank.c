static int DVMH_VARIABLE_ARRAY_SIZE = 0;

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1)), reduction(), private(), remote_access(), across()
void loop_adi_41(double a[][384][384]) {
    int i;
    int j;
    int k;

            {
                a[i][j][k] = (a[i - 1][j][k] + a[i + 1][j][k]) / 2;
            }

}

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1)), reduction(), private(), remote_access(), across()
void loop_adi_46(double a[][384][384]) {
    int i;
    int j;
    int k;

            {
                a[i][j][k] = (a[i][j - 1][k] + a[i][j + 1][k]) / 2;
            }

}

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1)), reduction(max(eps)), private(), remote_access(), across()
void loop_adi_51(double a[][384][384]) {
    int i;
    int j;
    int k;
    double eps;

            {
              double tmp1 = (a[i][j][k - 1] + a[i][j][k + 1]) / 2;
              double tmp2 = fabs(a[i][j][k] - tmp1);
              eps = ((eps) > (tmp2) ? (eps) : (tmp2));
              a[i][j][k] = tmp1;
            }

}

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1)), reduction(), private(), remote_access()
void loop_adi_92(double a[][384][384]) {
    int i;
    int j;
    int k;

            {
                if (k == 0 || k == 384 - 1 || j == 0 || j == 384 - 1 || i == 0 || i == 384 - 1)
                  a[i][j][k] = 10. * i / (384 - 1) + 10. * j / (384 - 1) + 10. * k / (384 - 1);
                else
                  a[i][j][k] = 0;
            }

}

