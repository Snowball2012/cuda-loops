      program adi
      integer  nx,ny,nz,itmax
      double precision  eps,relax,maxeps
      double precision  startt,endt,dvtime
      parameter (nx = 384,ny = 384,nz = 384,maxeps = 0.01,itmax = 100)

! DVMH declarations 
      integer*8 ,parameter:: HANDLER_TYPE_PARALLEL = 1,HANDLER_TYPE_MAST
     &ER = 2
      integer*8 ,parameter:: DEVICE_TYPE_HOST = 1,DEVICE_TYPE_CUDA = 2
      integer*8 ,parameter:: INTENT_INOUT = 3
      external loop_adi_16_cuda,loop_adi_16_host,loop_adi_16_host_1,loop
     &_adi_16_host_2,loop_adi_16_host_3,loop_adi_16_host_0,loop_adi_24_c
     &uda,loop_adi_24_host,loop_adi_24_host_1,loop_adi_24_host_2,loop_ad
     &i_24_host_3,loop_adi_24_host_0,loop_adi_33_cuda,loop_adi_33_host,l
     &oop_adi_33_host_1,loop_adi_33_host_2,loop_adi_33_host_3,loop_adi_3
     &3_host_0
      external loop_across,dvmh_actual_variable,dvmh_get_actual_variable
     &,loop_insred,loop_perform,loop_register_handler,dvmh_shadow_renew,
     &region_set_name_array,region_register_array,region_execute_on_targ
     &ets,region_end,dvmh_finish,dvmh_init,ftcntr,dvmlf,eiof,biof,clfdvm
      integer*8  dvmh_get_next_stage,loop_create,region_create,bsynch,ac
     &ross,insshd,delobj,tstio,getach,getad,getaf,getal,getai,dopl,endpl
     &,mappl,crtpl,crtshg,waitrd,strtrd,insred,crtrg,crtrdf,align,crtda,
     &distr,crtamv,lexit,linit
      integer*8  dvm000(90)
      integer*8  a(50)
      character*23  filenm001
      double precision  pipe00
      integer*8  a0005,a0003,a0002
      common /adidvm/eps
      integer*8  dvm0c9,dvm0c8,dvm0c7,dvm0c6,dvm0c5,dvm0c4,dvm0c3,dvm0c2
     &,dvm0c1,dvm0c0
      parameter (dvm0c9 = 9,dvm0c8 = 8,dvm0c7 = 7,dvm0c6 = 6,dvm0c5 = 5,
     &dvm0c4 = 4,dvm0c3 = 3,dvm0c2 = 2,dvm0c1 = 1,dvm0c0 = 0)
      character  ch000m(0:64)
      logical  l0000m(0:64)
      double precision  d0000m(0:64)
      real  r0000m(0:64)
      integer  i0000m(0:64)
      equivalence (l0000m,d0000m,r0000m,i0000m)
      common /mem000/i0000m
      data filenm001/'../cdv-fdv-src/adi.fdv '/ 
      filenm001(23:23) = char (0)
      call dvmlf(8_8,filenm001)
      dvm000(1) = dvm0c6
      dvm000(2) = getai (dvm000(1))
      dvm000(3) = getai (i0000m(0))
      dvm000(4) = getal (l0000m(0))
      dvm000(5) = getaf (r0000m(0))
      dvm000(6) = getad (d0000m(0))
      dvm000(7) = getach (ch000m(0))
      dvm000(8) = getai (dvm000(2))
      dvm000(9) = getai (i0000m(1))
      dvm000(10) = getal (l0000m(1))
      dvm000(11) = getaf (r0000m(1))
      dvm000(12) = getad (d0000m(1))
      dvm000(13) = getach (ch000m(1))
      i0000m(0) = 8
      i0000m(1) = 4
      i0000m(2) = 4
      i0000m(3) = 4
      i0000m(4) = 8
      i0000m(5) = 1
      i0000m(10) = 2
      i0000m(11) = 1
      i0000m(12) = 1
      i0000m(13) = 3
      i0000m(14) = 4
      i0000m(15) = 5
      call ftcntr(6,dvm000(2),dvm000(8),i0000m(0),i0000m(10))
      dvm000(1) = linit (dvm0c0)
      dvm000(2) = 1

!$    dvm000(2) = dvm000(2) + 8 
      call dvmh_init(dvm000(2))
      dvm000(4) = 3
      dvm000(5) = 2
      dvm000(6) = 1
      dvm000(7) = 0
      dvm000(8) = 0
      dvm000(9) = 0
      call dvmlf(7_8,filenm001)
      dvm000(10) = 384
      dvm000(11) = 384
      dvm000(12) = 384
      dvm000(13) = crtamv (dvm0c0,dvm0c3,dvm000(10),dvm0c0)
      dvm000(14) = distr (dvm000(13),dvm0c0,dvm0c3,dvm000(4),dvm000(7))
      dvm000(15) = 1
      dvm000(16) = 1
      dvm000(17) = 1
      a(6) = 1
      a(7) = 1
      a(8) = 1
      a(9) = 10
      dvm000(18) = crtda (a(1),dvm0c1,i0000m,dvm0c3,(-(dvm0c4)),dvm000(1
     &0),dvm0c0,dvm0c0,dvm000(15),dvm000(15))
      dvm000(19) = 1
      dvm000(20) = 2
      dvm000(21) = 3
      dvm000(22) = 1
      dvm000(23) = 1
      dvm000(24) = 1
      dvm000(25) = 0
      dvm000(26) = 0
      dvm000(27) = 0
      dvm000(28) = align (a(1),dvm000(13),dvm000(19),dvm000(22),dvm000(2
     &5))
      call init(a,nx,ny,nz)
      call dvmlf(9_8,filenm001)
      dvm000(14) = bsynch ()
      startt = dvtime ()
      do  it = 1,itmax
         eps = 0.d0
         call dvmlf(13_8,filenm001)
         call dvmh_actual_variable(eps)
         call dvmlf(14_8,filenm001)

! Start region (line 14)
         dvm000(14) = region_create (dvm0c0)
         call region_register_array(dvm000(14),INTENT_INOUT,a(1))
         call region_set_name_array(dvm000(14),a(1),'a')
         call region_execute_on_targets(dvm000(14),ior (DEVICE_TYPE_HOST
     &,DEVICE_TYPE_CUDA))
         call dvmlf(15_8,filenm001)
         dvm000(15) = crtpl (dvm0c3)
         dvm000(31) = 0
         dvm000(32) = 0
         dvm000(33) = 1
         dvm000(34) = 0
         dvm000(35) = 0
         dvm000(36) = 0
         dvm000(37) = 1
         dvm000(38) = 1
         dvm000(39) = 3
         dvm000(25) = crtshg (dvm0c0)
         dvm000(28) = crtshg (dvm0c0)
         dvm000(40) = insshd (dvm000(25),a(1),dvm000(31),dvm000(34),dvm0
     &c1,dvm000(37))
         dvm000(41) = insshd (dvm000(28),a(1),dvm000(31),dvm000(34),dvm0
     &c1,dvm000(37))
         dvm000(42) = 0
         dvm000(43) = 0
         dvm000(44) = 0
         dvm000(45) = 0
         dvm000(46) = 0
         dvm000(47) = 1
         dvm000(48) = 1
         dvm000(49) = 1
         dvm000(50) = 5
         dvm000(27) = crtshg (dvm0c0)
         dvm000(30) = crtshg (dvm0c0)
         dvm000(51) = insshd (dvm000(27),a(1),dvm000(42),dvm000(45),dvm0
     &c1,dvm000(48))
         dvm000(52) = insshd (dvm000(30),a(1),dvm000(42),dvm000(45),dvm0
     &c1,dvm000(48))
         dvm000(53) = getai (k)
         dvm000(54) = getai (j)
         dvm000(55) = getai (i)
         dvm000(56) = 1
         dvm000(57) = 1
         dvm000(58) = 1
         dvm000(59) = 2
         dvm000(60) = 2
         dvm000(61) = 2
         dvm000(62) = nz - 1
         dvm000(63) = ny - 1
         dvm000(64) = nx - 1
         dvm000(65) = 1
         dvm000(66) = 1
         dvm000(67) = 1
         dvm000(68) = 1
         dvm000(69) = 2
         dvm000(70) = 3
         dvm000(71) = 1
         dvm000(72) = 1
         dvm000(73) = 1
         dvm000(74) = (-1)
         dvm000(75) = (-1)
         dvm000(76) = (-1)
         dvm000(77) = mappl (dvm000(15),a(1),dvm000(68),dvm000(71),dvm00
     &0(74),dvm000(53),dvm000(56),dvm000(59),dvm000(62),dvm000(65),dvm00
     &0(16),dvm000(19),dvm000(22))
         pipe00 = dvmh_get_next_stage (dvm000(14),dvm000(15),16_8,filenm
     &001)
         call dvmh_shadow_renew(dvm000(27))
         dvm000(78) = across (dvm0c0,dvm000(27),dvm000(25),pipe00)
90000    continue
         call dvmlf(16_8,filenm001)
         dvm000(79) = dopl (dvm000(15))
         if (dvm000(79) .eq. 0)          goto 89999

! Parallel loop (line 16)
         dvm000(80) = loop_create (dvm000(14),dvm000(15))
         call loop_register_handler(dvm000(80),DEVICE_TYPE_CUDA,dvm0c0,l
     &oop_adi_16_cuda,dvm0c0,dvm0c1,a)
         dvm000(81) = 0

!$    dvm000(81) = ior(HANDLER_TYPE_MASTER,HANDLER_TYPE_PARALLEL) 
         call loop_register_handler(dvm000(80),DEVICE_TYPE_HOST,dvm000(8
     &1),loop_adi_16_host,dvm0c0,dvm0c2,a,d0000m)
         call loop_across(dvm000(80),dvm000(30),dvm000(28))

! Loop execution
         call loop_perform(dvm000(80))
         goto 90000
89999    continue
         call dvmlf(22_8,filenm001)
         dvm000(82) = endpl (dvm000(15))
         call dvmlf(23_8,filenm001)
         dvm000(15) = crtpl (dvm0c3)
         dvm000(31) = 0
         dvm000(32) = 1
         dvm000(33) = 0
         dvm000(34) = 0
         dvm000(35) = 0
         dvm000(36) = 0
         dvm000(37) = 1
         dvm000(38) = 3
         dvm000(39) = 1
         dvm000(25) = crtshg (dvm0c0)
         dvm000(28) = crtshg (dvm0c0)
         dvm000(40) = insshd (dvm000(25),a(1),dvm000(31),dvm000(34),dvm0
     &c1,dvm000(37))
         dvm000(41) = insshd (dvm000(28),a(1),dvm000(31),dvm000(34),dvm0
     &c1,dvm000(37))
         dvm000(42) = 0
         dvm000(43) = 0
         dvm000(44) = 0
         dvm000(45) = 0
         dvm000(46) = 1
         dvm000(47) = 0
         dvm000(48) = 1
         dvm000(49) = 5
         dvm000(50) = 1
         dvm000(27) = crtshg (dvm0c0)
         dvm000(30) = crtshg (dvm0c0)
         dvm000(51) = insshd (dvm000(27),a(1),dvm000(42),dvm000(45),dvm0
     &c1,dvm000(48))
         dvm000(52) = insshd (dvm000(30),a(1),dvm000(42),dvm000(45),dvm0
     &c1,dvm000(48))
         dvm000(53) = getai (k)
         dvm000(54) = getai (j)
         dvm000(55) = getai (i)
         dvm000(56) = 1
         dvm000(57) = 1
         dvm000(58) = 1
         dvm000(59) = 2
         dvm000(60) = 2
         dvm000(61) = 2
         dvm000(62) = nz - 1
         dvm000(63) = ny - 1
         dvm000(64) = nx - 1
         dvm000(65) = 1
         dvm000(66) = 1
         dvm000(67) = 1
         dvm000(68) = 1
         dvm000(69) = 2
         dvm000(70) = 3
         dvm000(71) = 1
         dvm000(72) = 1
         dvm000(73) = 1
         dvm000(74) = (-1)
         dvm000(75) = (-1)
         dvm000(76) = (-1)
         dvm000(77) = mappl (dvm000(15),a(1),dvm000(68),dvm000(71),dvm00
     &0(74),dvm000(53),dvm000(56),dvm000(59),dvm000(62),dvm000(65),dvm00
     &0(16),dvm000(19),dvm000(22))
         pipe00 = dvmh_get_next_stage (dvm000(14),dvm000(15),24_8,filenm
     &001)
         call dvmh_shadow_renew(dvm000(27))
         dvm000(78) = across (dvm0c0,dvm000(27),dvm000(25),pipe00)
89993    continue
         call dvmlf(24_8,filenm001)
         dvm000(79) = dopl (dvm000(15))
         if (dvm000(79) .eq. 0)          goto 89992

! Parallel loop (line 24)
         dvm000(80) = loop_create (dvm000(14),dvm000(15))
         call loop_register_handler(dvm000(80),DEVICE_TYPE_CUDA,dvm0c0,l
     &oop_adi_24_cuda,dvm0c0,dvm0c1,a)
         dvm000(81) = 0

!$    dvm000(81) = ior(HANDLER_TYPE_MASTER,HANDLER_TYPE_PARALLEL) 
         call loop_register_handler(dvm000(80),DEVICE_TYPE_HOST,dvm000(8
     &1),loop_adi_24_host,dvm0c0,dvm0c2,a,d0000m)
         call loop_across(dvm000(80),dvm000(30),dvm000(28))

! Loop execution
         call loop_perform(dvm000(80))
         goto 89993
89992    continue
         call dvmlf(30_8,filenm001)
         dvm000(82) = endpl (dvm000(15))
         call dvmlf(31_8,filenm001)
         dvm000(53) = crtrg (dvm0c1,dvm0c1)
         dvm000(79) = 1
         dvm000(80) = 0
         call dvmh_get_actual_variable(eps)
         dvm000(81) = crtrdf (dvm0c3,getad (eps),dvm0c4,dvm000(79),dvm0c
     &0,dvm000(80),dvm0c1)
         dvm000(15) = crtpl (dvm0c3)
         dvm000(31) = 1
         dvm000(32) = 0
         dvm000(33) = 0
         dvm000(34) = 0
         dvm000(35) = 0
         dvm000(36) = 0
         dvm000(37) = 3
         dvm000(38) = 1
         dvm000(39) = 1
         dvm000(25) = crtshg (dvm0c0)
         dvm000(28) = crtshg (dvm0c0)
         dvm000(40) = insshd (dvm000(25),a(1),dvm000(31),dvm000(34),dvm0
     &c1,dvm000(37))
         dvm000(41) = insshd (dvm000(28),a(1),dvm000(31),dvm000(34),dvm0
     &c1,dvm000(37))
         dvm000(42) = 0
         dvm000(43) = 0
         dvm000(44) = 0
         dvm000(45) = 1
         dvm000(46) = 0
         dvm000(47) = 0
         dvm000(48) = 5
         dvm000(49) = 1
         dvm000(50) = 1
         dvm000(27) = crtshg (dvm0c0)
         dvm000(30) = crtshg (dvm0c0)
         dvm000(51) = insshd (dvm000(27),a(1),dvm000(42),dvm000(45),dvm0
     &c1,dvm000(48))
         dvm000(52) = insshd (dvm000(30),a(1),dvm000(42),dvm000(45),dvm0
     &c1,dvm000(48))
         dvm000(54) = getai (k)
         dvm000(55) = getai (j)
         dvm000(56) = getai (i)
         dvm000(57) = 1
         dvm000(58) = 1
         dvm000(59) = 1
         dvm000(60) = 2
         dvm000(61) = 2
         dvm000(62) = 2
         dvm000(63) = nz - 1
         dvm000(64) = ny - 1
         dvm000(65) = nx - 1
         dvm000(66) = 1
         dvm000(67) = 1
         dvm000(68) = 1
         dvm000(69) = 1
         dvm000(70) = 2
         dvm000(71) = 3
         dvm000(72) = 1
         dvm000(73) = 1
         dvm000(74) = 1
         dvm000(75) = (-1)
         dvm000(76) = (-1)
         dvm000(77) = (-1)
         dvm000(78) = mappl (dvm000(15),a(1),dvm000(69),dvm000(72),dvm00
     &0(75),dvm000(54),dvm000(57),dvm000(60),dvm000(63),dvm000(66),dvm00
     &0(16),dvm000(19),dvm000(22))
         dvm000(82) = insred (dvm000(53),dvm000(81),dvm000(15),dvm0c0)
         pipe00 = dvmh_get_next_stage (dvm000(14),dvm000(15),33_8,filenm
     &001)
         call dvmh_shadow_renew(dvm000(27))
         dvm000(83) = across (dvm0c0,dvm000(27),dvm000(25),pipe00)
89986    continue
         call dvmlf(33_8,filenm001)
         dvm000(84) = dopl (dvm000(15))
         if (dvm000(84) .eq. 0)          goto 89985

! Parallel loop (line 33)
         dvm000(85) = loop_create (dvm000(14),dvm000(15))
         call loop_insred(dvm000(85),dvm000(81))
         call loop_register_handler(dvm000(85),DEVICE_TYPE_CUDA,dvm0c0,l
     &oop_adi_33_cuda,dvm0c0,dvm0c1,a)
         dvm000(86) = 0

!$    dvm000(86) = ior(HANDLER_TYPE_MASTER,HANDLER_TYPE_PARALLEL) 
         call loop_register_handler(dvm000(85),DEVICE_TYPE_HOST,dvm000(8
     &6),loop_adi_33_host,dvm0c0,dvm0c2,a,d0000m)
         call loop_across(dvm000(85),dvm000(30),dvm000(28))

! Loop execution
         call loop_perform(dvm000(85))
         goto 89986
89985    continue
         call dvmlf(41_8,filenm001)
         dvm000(87) = endpl (dvm000(15))
         dvm000(88) = getad (eps)
         dvm000(88) = strtrd (dvm000(53))
         dvm000(89) = waitrd (dvm000(53))
         call dvmh_actual_variable(eps)
         dvm000(90) = delobj (dvm000(53))

! Region end (line 14)
         call dvmlf(42_8,filenm001)
         call region_end(dvm000(14))
         call dvmlf(43_8,filenm001)
         call dvmh_get_actual_variable(eps)
         call dvmlf(44_8,filenm001)
         call biof()
         if (tstio () .ne. 0)          print 200, it,eps
         call eiof()
200         format (' IT = ', i4, '   EPS = ', e14.7)
         if (eps .lt. maxeps)          exit 
      enddo  
      call dvmlf(48_8,filenm001)
      dvm000(14) = bsynch ()
      endt = dvtime ()
      call dvmlf(51_8,filenm001)
      call biof()
      if (tstio () .ne. 0)       print *, 'ADI Benchmark Completed.'
      call eiof()
      call dvmlf(52_8,filenm001)
      call biof()
      if (tstio () .ne. 0)       print 201, nx,ny,nz
      call eiof()
201    format (' Size            = ', i4, ' x ', i4, ' x ', i4)
      call dvmlf(54_8,filenm001)
      call biof()
      if (tstio () .ne. 0)       print 202, itmax
      call eiof()
202    format (' Iterations      =       ', i12)
      call dvmlf(56_8,filenm001)
      call biof()
      if (tstio () .ne. 0)       print 203, endt - startt
      call eiof()
203    format (' Time in seconds =       ', f12.2)
      call dvmlf(58_8,filenm001)
      call biof()
      if (tstio () .ne. 0)       print *, 'Operation type  =   double pr
     &ecision'
      call eiof()
      if (abs (eps - 0.07249074) .lt. 1.0e-6) then
         call dvmlf(60_8,filenm001)
         call biof()
         if (tstio () .ne. 0)          print *, 'Verification    =      
     &   SUCCESSFUL'
         call eiof()
      else  
         call dvmlf(62_8,filenm001)
         call biof()
         if (tstio () .ne. 0)          print *, 'Verification    =      
     & UNSUCCESSFUL'
         call eiof()
      endif  
      call dvmlf(65_8,filenm001)
      call biof()
      if (tstio () .ne. 0)       print *, 'END OF ADI Benchmark'
      call eiof()
      call dvmlf(66_8,filenm001)
      call clfdvm()
      call dvmh_finish()
      dvm000(14) = lexit (dvm0c0)
      end

      subroutine init (a, nx, ny, nz)
      integer  nx,ny,nz

! DVMH declarations 
      integer*8 ,parameter:: HANDLER_TYPE_PARALLEL = 1,HANDLER_TYPE_MAST
     &ER = 2
      integer*8 ,parameter:: DEVICE_TYPE_HOST = 1,DEVICE_TYPE_CUDA = 2
      integer*8 ,parameter:: INTENT_OUT = 2
      external loop_adi_74_cuda,loop_adi_74_host
      external dvmh_get_actual_variable,loop_perform,loop_register_handl
     &er,region_set_name_array,region_register_array,region_execute_on_t
     &argets,region_end,dvmlf
      integer*8  loop_create,region_create,getai,dopl,endpl,mappl,crtpl
      integer*8  dvm000(43)
      integer*8  a(50)
      character*23  filenm001
      integer*8  a0005,a0003,a0002
      integer*8  dvm0c9,dvm0c8,dvm0c7,dvm0c6,dvm0c5,dvm0c4,dvm0c3,dvm0c2
     &,dvm0c1,dvm0c0
      parameter (dvm0c9 = 9,dvm0c8 = 8,dvm0c7 = 7,dvm0c6 = 6,dvm0c5 = 5,
     &dvm0c4 = 4,dvm0c3 = 3,dvm0c2 = 2,dvm0c1 = 1,dvm0c0 = 0)
      double precision  d0000m(0:64)
      integer  i0000m(0:64)
      equivalence (d0000m,i0000m)
      common /mem000/i0000m
      data filenm001/'../cdv-fdv-src/adi.fdv '/ 
      filenm001(23:23) = char (0)
      call dvmlf(72_8,filenm001)
      call dvmh_get_actual_variable(nz)
      call dvmh_get_actual_variable(ny)
      call dvmh_get_actual_variable(nx)

! Start region (line 72)
      dvm000(4) = region_create (dvm0c0)
      call region_register_array(dvm000(4),INTENT_OUT,a(1))
      call region_set_name_array(dvm000(4),a(1),'a')
      call region_execute_on_targets(dvm000(4),ior (DEVICE_TYPE_HOST,DEV
     &ICE_TYPE_CUDA))
      call dvmlf(73_8,filenm001)
      call dvmh_get_actual_variable(nz)
      call dvmh_get_actual_variable(ny)
      call dvmh_get_actual_variable(nx)
      dvm000(5) = crtpl (dvm0c3)
      dvm000(15) = getai (k)
      dvm000(16) = getai (j)
      dvm000(17) = getai (i)
      dvm000(18) = 1
      dvm000(19) = 1
      dvm000(20) = 1
      dvm000(21) = 1
      dvm000(22) = 1
      dvm000(23) = 1
      dvm000(24) = nz
      dvm000(25) = ny
      dvm000(26) = nx
      dvm000(27) = 1
      dvm000(28) = 1
      dvm000(29) = 1
      dvm000(30) = 1
      dvm000(31) = 2
      dvm000(32) = 3
      dvm000(33) = 1
      dvm000(34) = 1
      dvm000(35) = 1
      dvm000(36) = (-1)
      dvm000(37) = (-1)
      dvm000(38) = (-1)
      dvm000(39) = mappl (dvm000(5),a(1),dvm000(30),dvm000(33),dvm000(36
     &),dvm000(15),dvm000(18),dvm000(21),dvm000(24),dvm000(27),dvm000(6)
     &,dvm000(9),dvm000(12))
89979 continue
      call dvmlf(74_8,filenm001)
      dvm000(40) = dopl (dvm000(5))
      if (dvm000(40) .eq. 0)       goto 89978

! Parallel loop (line 74)
      dvm000(41) = loop_create (dvm000(4),dvm000(5))
      call loop_register_handler(dvm000(41),DEVICE_TYPE_CUDA,dvm0c0,loop
     &_adi_74_cuda,dvm0c0,dvm0c4,a,nz,ny,nx)
      dvm000(42) = 0

!$    dvm000(42) = ior(HANDLER_TYPE_MASTER,HANDLER_TYPE_PARALLEL) 
      call loop_register_handler(dvm000(41),DEVICE_TYPE_HOST,dvm000(42),
     &loop_adi_74_host,dvm0c0,dvm0c5,a,d0000m,nz,ny,nx)

! Loop execution
      call loop_perform(dvm000(41))
      goto 89979
89978 continue
      call dvmlf(86_8,filenm001)
      dvm000(43) = endpl (dvm000(5))

! Region end (line 72)
      call dvmlf(87_8,filenm001)
      call region_end(dvm000(4))
      end


!-----------------------------------------------------------------------


!     Host handler for loop on line 16 

      recursive subroutine loop_adi_16_host_1 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i)
!$OMP    DO  SCHEDULE (runtime)
         do  k = boundsLow(1),boundsHigh(1)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + (i - 1) + a0003 * j + a0002 * k) + d0000m(a0005 + (i + 1) + 
     &a0003 * j + a0002 * k)) / 2
               enddo  
            enddo  
         enddo  
!$OMP    END DO  NOWAIT
!$OMP END PARALLEL 
      end subroutine



!     Host handler for loop on line 16 

      recursive subroutine loop_adi_16_host_2 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i)
         do  k = boundsLow(1),boundsHigh(1)
!$OMP       DO  SCHEDULE (runtime)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + (i - 1) + a0003 * j + a0002 * k) + d0000m(a0005 + (i + 1) + 
     &a0003 * j + a0002 * k)) / 2
               enddo  
            enddo  
!$OMP       END DO  NOWAIT
         enddo  
!$OMP END PARALLEL 
      end subroutine



!     Host handler for loop on line 16 

      recursive subroutine loop_adi_16_host_3 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i)
         do  k = boundsLow(1),boundsHigh(1)
            do  j = boundsLow(2),boundsHigh(2)
!$OMP          DO  SCHEDULE (runtime)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + (i - 1) + a0003 * j + a0002 * k) + d0000m(a0005 + (i + 1) + 
     &a0003 * j + a0002 * k)) / 2
               enddo  
!$OMP          END DO  NOWAIT
            enddo  
         enddo  
!$OMP END PARALLEL 
      end subroutine



!     Host handler for loop on line 16 

      recursive subroutine loop_adi_16_host_0 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
!$      integer*8  omp_get_thread_num
!$      integer  ilimit
!$      integer  iam
!$      integer  isync
!$      allocatable:: isync(:)
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$      allocate(isync(0:lgsc - 1))
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i),PRIVATE (iam,ilimit)
!$         ilimit = min (lgsc - 1,boundsHigh(2) - boundsLow(2))
!$         iam = omp_get_thread_num ()
!$         isync(iam) = 0
!$OMP    BARRIER
         do  k = boundsLow(1),boundsHigh(1)
!$            if (iam .gt. 0 .and. iam .le. ilimit) then
!$               do while (isync(iam - 1) .eq. 0)
!$OMP             FLUSH  ( isync )
!$               enddo  
!$               isync(iam - 1) = 0
!$OMP          FLUSH  ( isync )
!$            endif  
!$OMP       DO  SCHEDULE (static)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + (i - 1) + a0003 * j + a0002 * k) + d0000m(a0005 + (i + 1) + 
     &a0003 * j + a0002 * k)) / 2
               enddo  
            enddo  
!$OMP       END DO  NOWAIT
!$            if (iam .lt. ilimit) then
!$               do while (isync(iam) .eq. 1)
!$OMP             FLUSH  ( isync )
!$               enddo  
!$               isync(iam) = 1
!$OMP          FLUSH  ( isync )
!$            endif  
         enddo  
!$OMP END PARALLEL 
!$      deallocate(isync)
      end subroutine



!     Host handler for loop on line 16 

      recursive subroutine loop_adi_16_host (loop_ref,a,d0000m)
      implicit none
      integer*8  which_run
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      external loop_adi_16_host_1
      external loop_adi_16_host_2
      external loop_adi_16_host_3
      external loop_adi_16_host_0
      integer*8  loop_get_dependency_mask
      which_run = not (loop_get_dependency_mask (loop_ref))
      if (btest (which_run,2)) then
         call loop_adi_16_host_1(loop_ref,a,d0000m)
      else  
         if (btest (which_run,1)) then
            call loop_adi_16_host_2(loop_ref,a,d0000m)
         else  
            if (btest (which_run,0)) then
               call loop_adi_16_host_3(loop_ref,a,d0000m)
            else  
               call loop_adi_16_host_0(loop_ref,a,d0000m)
            endif  
         endif  
      endif  
      end subroutine



!     Host handler for loop on line 24 

      recursive subroutine loop_adi_24_host_1 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i)
!$OMP    DO  SCHEDULE (runtime)
         do  k = boundsLow(1),boundsHigh(1)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * (j - 1) + a0002 * k) + d0000m(a0005 + i + a0003 
     &* (j + 1) + a0002 * k)) / 2
               enddo  
            enddo  
         enddo  
!$OMP    END DO  NOWAIT
!$OMP END PARALLEL 
      end subroutine



!     Host handler for loop on line 24 

      recursive subroutine loop_adi_24_host_2 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i)
         do  k = boundsLow(1),boundsHigh(1)
!$OMP       DO  SCHEDULE (runtime)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * (j - 1) + a0002 * k) + d0000m(a0005 + i + a0003 
     &* (j + 1) + a0002 * k)) / 2
               enddo  
            enddo  
!$OMP       END DO  NOWAIT
         enddo  
!$OMP END PARALLEL 
      end subroutine



!     Host handler for loop on line 24 

      recursive subroutine loop_adi_24_host_3 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i)
         do  k = boundsLow(1),boundsHigh(1)
            do  j = boundsLow(2),boundsHigh(2)
!$OMP          DO  SCHEDULE (runtime)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * (j - 1) + a0002 * k) + d0000m(a0005 + i + a0003 
     &* (j + 1) + a0002 * k)) / 2
               enddo  
!$OMP          END DO  NOWAIT
            enddo  
         enddo  
!$OMP END PARALLEL 
      end subroutine



!     Host handler for loop on line 24 

      recursive subroutine loop_adi_24_host_0 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
!$      integer*8  omp_get_thread_num
!$      integer  ilimit
!$      integer  iam
!$      integer  isync
!$      allocatable:: isync(:)
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
!$      lgsc = loop_get_slot_count (loop_ref)
!$      allocate(isync(0:lgsc - 1))
!$OMP PARALLEL  NUM_THREADS (lgsc),PRIVATE (k,j,i),PRIVATE (iam,ilimit)
!$         ilimit = min (lgsc - 1,boundsHigh(2) - boundsLow(2))
!$         iam = omp_get_thread_num ()
!$         isync(iam) = 0
!$OMP    BARRIER
         do  k = boundsLow(1),boundsHigh(1)
!$            if (iam .gt. 0 .and. iam .le. ilimit) then
!$               do while (isync(iam - 1) .eq. 0)
!$OMP             FLUSH  ( isync )
!$               enddo  
!$               isync(iam - 1) = 0
!$OMP          FLUSH  ( isync )
!$            endif  
!$OMP       DO  SCHEDULE (static)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * (j - 1) + a0002 * k) + d0000m(a0005 + i + a0003 
     &* (j + 1) + a0002 * k)) / 2
               enddo  
            enddo  
!$OMP       END DO  NOWAIT
!$            if (iam .lt. ilimit) then
!$               do while (isync(iam) .eq. 1)
!$OMP             FLUSH  ( isync )
!$               enddo  
!$               isync(iam) = 1
!$OMP          FLUSH  ( isync )
!$            endif  
         enddo  
!$OMP END PARALLEL 
!$      deallocate(isync)
      end subroutine



!     Host handler for loop on line 24 

      recursive subroutine loop_adi_24_host (loop_ref,a,d0000m)
      implicit none
      integer*8  which_run
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      external loop_adi_24_host_1
      external loop_adi_24_host_2
      external loop_adi_24_host_3
      external loop_adi_24_host_0
      integer*8  loop_get_dependency_mask
      which_run = not (loop_get_dependency_mask (loop_ref))
      if (btest (which_run,2)) then
         call loop_adi_24_host_1(loop_ref,a,d0000m)
      else  
         if (btest (which_run,1)) then
            call loop_adi_24_host_2(loop_ref,a,d0000m)
         else  
            if (btest (which_run,0)) then
               call loop_adi_24_host_3(loop_ref,a,d0000m)
            else  
               call loop_adi_24_host_0(loop_ref,a,d0000m)
            endif  
         endif  
      endif  
      end subroutine



!     Host handler for loop on line 33 

      recursive subroutine loop_adi_33_host_1 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      double precision  eps
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_red_post,loop_red_init,loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
      call loop_red_init(loop_ref,1_8,eps,0_8)
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),REDUCTION (max:eps),PRIVATE (k,j,i)
!$OMP    DO  SCHEDULE (runtime)
         do  k = boundsLow(1),boundsHigh(1)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  eps = max (eps,abs (d0000m(a0005 + i + a0003 * j + a00
     &02 * k) - (d0000m(a0005 + i + a0003 * j + a0002 * (k - 1)) + d0000
     &m(a0005 + i + a0003 * j + a0002 * (k + 1))) / 2))
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * j + a0002 * (k - 1)) + d0000m(a0005 + i + a0003 
     &* j + a0002 * (k + 1))) / 2
               enddo  
            enddo  
         enddo  
!$OMP    END DO  NOWAIT
!$OMP END PARALLEL 
      call loop_red_post(loop_ref,1_8,eps,0_8)
      end subroutine



!     Host handler for loop on line 33 

      recursive subroutine loop_adi_33_host_2 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      double precision  eps
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_red_post,loop_red_init,loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
      call loop_red_init(loop_ref,1_8,eps,0_8)
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),REDUCTION (max:eps),PRIVATE (k,j,i)
         do  k = boundsLow(1),boundsHigh(1)
!$OMP       DO  SCHEDULE (runtime)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  eps = max (eps,abs (d0000m(a0005 + i + a0003 * j + a00
     &02 * k) - (d0000m(a0005 + i + a0003 * j + a0002 * (k - 1)) + d0000
     &m(a0005 + i + a0003 * j + a0002 * (k + 1))) / 2))
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * j + a0002 * (k - 1)) + d0000m(a0005 + i + a0003 
     &* j + a0002 * (k + 1))) / 2
               enddo  
            enddo  
!$OMP       END DO  NOWAIT
         enddo  
!$OMP END PARALLEL 
      call loop_red_post(loop_ref,1_8,eps,0_8)
      end subroutine



!     Host handler for loop on line 33 

      recursive subroutine loop_adi_33_host_3 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      double precision  eps
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_red_post,loop_red_init,loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
      call loop_red_init(loop_ref,1_8,eps,0_8)
!$      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL  NUM_THREADS (lgsc),REDUCTION (max:eps),PRIVATE (k,j,i)
         do  k = boundsLow(1),boundsHigh(1)
            do  j = boundsLow(2),boundsHigh(2)
!$OMP          DO  SCHEDULE (runtime)
               do  i = boundsLow(3),boundsHigh(3)
                  eps = max (eps,abs (d0000m(a0005 + i + a0003 * j + a00
     &02 * k) - (d0000m(a0005 + i + a0003 * j + a0002 * (k - 1)) + d0000
     &m(a0005 + i + a0003 * j + a0002 * (k + 1))) / 2))
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * j + a0002 * (k - 1)) + d0000m(a0005 + i + a0003 
     &* j + a0002 * (k + 1))) / 2
               enddo  
!$OMP          END DO  NOWAIT
            enddo  
         enddo  
!$OMP END PARALLEL 
      call loop_red_post(loop_ref,1_8,eps,0_8)
      end subroutine



!     Host handler for loop on line 33 

      recursive subroutine loop_adi_33_host_0 (loop_ref,a,d0000m)
      implicit none
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      double precision  eps
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_red_post,loop_red_init,loop_fill_bounds
!$      integer*8  omp_get_thread_num
!$      integer  ilimit
!$      integer  iam
!$      integer  isync
!$      allocatable:: isync(:)
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
      call loop_red_init(loop_ref,1_8,eps,0_8)
!$      lgsc = loop_get_slot_count (loop_ref)
!$      allocate(isync(0:lgsc - 1))
!$OMP PARALLEL  NUM_THREADS (lgsc),REDUCTION (max:eps),PRIVATE (k,j,i),P
!$OMP&RIVATE (iam,ilimit)
!$         ilimit = min (lgsc - 1,boundsHigh(2) - boundsLow(2))
!$         iam = omp_get_thread_num ()
!$         isync(iam) = 0
!$OMP    BARRIER
         do  k = boundsLow(1),boundsHigh(1)
!$            if (iam .gt. 0 .and. iam .le. ilimit) then
!$               do while (isync(iam - 1) .eq. 0)
!$OMP             FLUSH  ( isync )
!$               enddo  
!$               isync(iam - 1) = 0
!$OMP          FLUSH  ( isync )
!$            endif  
!$OMP       DO  SCHEDULE (static)
            do  j = boundsLow(2),boundsHigh(2)
               do  i = boundsLow(3),boundsHigh(3)
                  eps = max (eps,abs (d0000m(a0005 + i + a0003 * j + a00
     &02 * k) - (d0000m(a0005 + i + a0003 * j + a0002 * (k - 1)) + d0000
     &m(a0005 + i + a0003 * j + a0002 * (k + 1))) / 2))
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = (d0000m(a0
     &005 + i + a0003 * j + a0002 * (k - 1)) + d0000m(a0005 + i + a0003 
     &* j + a0002 * (k + 1))) / 2
               enddo  
            enddo  
!$OMP       END DO  NOWAIT
!$            if (iam .lt. ilimit) then
!$               do while (isync(iam) .eq. 1)
!$OMP             FLUSH  ( isync )
!$               enddo  
!$               isync(iam) = 1
!$OMP          FLUSH  ( isync )
!$            endif  
         enddo  
!$OMP END PARALLEL 
!$      deallocate(isync)
      call loop_red_post(loop_ref,1_8,eps,0_8)
      end subroutine



!     Host handler for loop on line 33 

      recursive subroutine loop_adi_33_host (loop_ref,a,d0000m)
      implicit none
      integer*8  which_run
      integer*8  loop_ref,a(5)
      double precision  d0000m(0:*)
      external loop_adi_33_host_1
      external loop_adi_33_host_2
      external loop_adi_33_host_3
      external loop_adi_33_host_0
      integer*8  loop_get_dependency_mask
      which_run = not (loop_get_dependency_mask (loop_ref))
      if (btest (which_run,2)) then
         call loop_adi_33_host_1(loop_ref,a,d0000m)
      else  
         if (btest (which_run,1)) then
            call loop_adi_33_host_2(loop_ref,a,d0000m)
         else  
            if (btest (which_run,0)) then
               call loop_adi_33_host_3(loop_ref,a,d0000m)
            else  
               call loop_adi_33_host_0(loop_ref,a,d0000m)
            endif  
         endif  
      endif  
      end subroutine



!     Host handler for loop on line 74 

      recursive subroutine loop_adi_74_host (loop_ref,a,d0000m,nz,ny,nx)
      implicit none
      integer*8  loop_ref,a(5)
      integer  nx
      integer  ny
      integer  nz
      double precision  d0000m(0:*)
      integer  i
      integer  j
      integer  k
      integer*8  a0005,a0003,a0002
      integer*8  boundsLow(3),boundsHigh(3),stepsIgnore(3)
      integer*8  lgsc
      integer*8  loop_get_slot_count
      external loop_fill_bounds
      a0002 = a(2)
      a0003 = a(3)
      a0005 = a(5)
      call loop_fill_bounds(loop_ref,boundsLow(1),boundsHigh(1),stepsIgn
     &ore(1))
      lgsc = loop_get_slot_count (loop_ref)
!$OMP PARALLEL DO  NUM_THREADS (lgsc),PRIVATE (k,j,i),SCHEDULE (runtime)
!$OMP&
      do  k = boundsLow(1),boundsHigh(1)
         do  j = boundsLow(2),boundsHigh(2)
            do  i = boundsLow(3),boundsHigh(3)
               if (k .eq. 1 .or. k .eq. nz .or. j .eq. 1 .or. j .eq. ny 
     &.or. i .eq. 1 .or. i .eq. nx) then
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = 10. * (i -
     & 1) / (nx - 1) + 10. * (j - 1) / (ny - 1) + 10. * (k - 1) / (nz - 
     &1)
               else  
                  d0000m(a0005 + i + a0003 * j + a0002 * k) = 0.e0
               endif  
            enddo  
         enddo  
      enddo  
      end subroutine


