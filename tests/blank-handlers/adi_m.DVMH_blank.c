static int DVMH_VARIABLE_ARRAY_SIZE = 0;

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1), p(1, 1)), reduction(), private(), remote_access(), across()
void loop_adi_m_42(double a[][384][384][384]) {
    int i;
    int j;
    int k;
    int p;

                {
                    a[i][j][k][p] = (a[i - 1][j][k][p] + a[i + 1][j][k][p]) / 2;
                }

}

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1), p(1, 1)), reduction(), private(), remote_access(), across()
void loop_adi_m_48(double a[][384][384][384]) {
    int i;
    int j;
    int k;
    int p;

                {
                    a[i][j][k][p] = (a[i][j - 1][k][p] + a[i][j + 1][k][p]) / 2;
                }

}

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1), p(1, 1)), reduction(max(eps)), private(), remote_access(), across()
void loop_adi_m_54(double a[][384][384][384]) {
    int i;
    int j;
    int k;
    int p;
    double eps;

                {
                  double tmp1 = (a[i][j][k - 1][p] + a[i][j][k + 1][p]) / 2;
                  double tmp2 = fabs(a[i][j][k][p] - tmp1);
                  eps = ((eps) > (tmp2) ? (eps) : (tmp2));
                  a[i][j][k][p] = tmp1;
                }

}

#pragma dvm handler_stub dvm_array(a), regular_array(), scalar(), loop_var(i(1, 1), j(1, 1), k(1, 1), p(1, 1)), reduction(max(eps)), private(), remote_access()
void loop_adi_m_96(double a[][384][384][384]) {
    int i;
    int j;
    int k;
    int p;
    double eps;

                {
                    if (k == 0 || k == 384 - 1 || j == 0 || j == 384 - 1 || i == 0 || i == 384 - 1)
                      a[i][j][k][p] = 10. * i / (384 - 1) + 10. * j / (384 - 1) + 10. * k / (384 - 1);
                    else
                      a[i][j][k][p] = 0;
                }

}

