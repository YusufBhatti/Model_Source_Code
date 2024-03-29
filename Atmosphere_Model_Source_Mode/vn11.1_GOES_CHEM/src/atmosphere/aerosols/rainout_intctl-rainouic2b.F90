! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! ******************************COPYRIGHT******************************
MODULE rainout_intctl_mod

IMPLICIT NONE

CHARACTER(LEN=*), PARAMETER, PRIVATE :: ModuleName='RAINOUT_INTCTL_MOD'

CONTAINS

SUBROUTINE rainout_intctl(                                                     &
  row_length, rows,                                                            &
  off_x, off_y, halo_i, halo_j,                                                &
  rho_r2, q,                                                                   &
  qcf_remain, qcl_remain,                                                      &
  qcf_previous, qcl_previous,                                                  &
  ls_rain3d, ls_snow3d,                                                        &
  timestep,                                                                    &
  aero_incloud, aero_accum,                                                    &
  rnout_aero)

!---------------------------------------------------------------------
! Purpose: Wrapper to version 2B of the aerosol rain-out routine.
!
!          Called by microphys_ctl (deck mcr_ctl2)
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section: Aerosols
!
! Code description:
!  Language: Fortran 90.
!  This code is written to UMDP3 v8 programming standards
!
! Documentation: UMDP 20
!
!---------------------------------------------------------------------


USE yomhook, ONLY: lhook, dr_hook
USE parkind1, ONLY: jprb, jpim
USE rainout_mod, ONLY: rainout
USE nlsizes_namelist_mod, ONLY: model_levels

IMPLICIT NONE

INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName='RAINOUT_INTCTL'

! Arguments with intent in:

INTEGER :: row_length
INTEGER :: rows
INTEGER :: off_x                !EW size of std. halo
INTEGER :: off_y                !NS size of std. halo
INTEGER :: halo_i               !EW extended halo
INTEGER :: halo_j               !NS extended halo

REAL :: rho_r2(1-off_x:row_length+off_x, 1-off_y:rows+off_y,model_levels)  !density*r*r

REAL :: qcl_remain(row_length,rows,model_levels)
REAL :: qcf_remain(row_length,rows,model_levels)
REAL :: qcf_previous(row_length,rows,model_levels)
REAL :: qcl_previous(row_length,rows,model_levels)
REAL :: q(row_length,rows,model_levels)
REAL :: ls_rain3d(row_length,rows,model_levels)
REAL :: ls_snow3d(row_length,rows,model_levels)

REAL :: timestep ! timestep in seconds

! Arguments with intent IN/OUT:
!   mass mixing ratio of in-cloud and accumulation/aged aerosol
REAL :: aero_incloud(1-off_x:row_length+off_x, 1-off_y:rows+off_y,             &
                     model_levels)
REAL :: aero_accum(1-off_x:row_length+off_x, 1-off_y:rows+off_y,               &
                   model_levels)

! Arguments with intent OUT (diagnostics):
REAL :: rnout_aero(row_length,rows)      !tracer removed kg/m2/ts


! No local variables

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)
CALL rainout(                                                                  &
  row_length, rows,                                                            &
  off_x, off_y, halo_i, halo_j,                                                &
  rho_r2, q,                                                                   &
  qcf_remain, qcl_remain,                                                      &
  qcf_previous, qcl_previous,                                                  &
  ls_rain3d, ls_snow3d,                                                        &
  timestep,                                                                    &
  aero_incloud,                                                                &
  aero_accum,                                                                  &
  rnout_aero)

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)
RETURN
END SUBROUTINE rainout_intctl
END MODULE rainout_intctl_mod
