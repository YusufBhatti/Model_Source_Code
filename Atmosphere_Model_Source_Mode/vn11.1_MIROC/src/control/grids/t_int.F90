! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
! SUBROUTINE T_INT:--------------------------------------------------
!
! Purpose:
!   Carries out linear interpolation in time between two fields.
!   If the missing data indicator is present at one of the
!   times, the value at the other time is used.
!
! Programming standard: UMDP3 v10.3
!
! System component: S190
!
! System task: S1
!
! Documentation:
!   The interpolation formulae are described in
!   unified model on-line documentation paper S1.
!
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section: Grids
MODULE t_int_mod

IMPLICIT NONE

CHARACTER(LEN=*), PARAMETER, PRIVATE :: ModuleName = 'T_INT_MOD'

CONTAINS

SUBROUTINE t_int( data_t1, t1, data_t2, t2, data_t3, t3, points )

USE missing_data_mod, ONLY: rmdi
USE yomhook,  ONLY: lhook, dr_hook
USE parkind1, ONLY: jprb, jpim

IMPLICIT NONE

INTEGER, INTENT(IN) :: points         ! Number of points to be processed

REAL, INTENT(IN)  :: data_t1(points)  ! Data at T1
REAL, INTENT(IN)  :: data_t2(points)  ! Data at T2
REAL, INTENT(OUT) :: data_t3(points)  ! Data at T3

REAL, INTENT(IN)  :: t1    ! Time of first data field
REAL, INTENT(IN)  :: t2    ! Time of second data field
REAL, INTENT(IN)  :: t3    ! Time at which new field is required T1<=T3<=T2


! Local variables:------------------------------------------------------
REAL :: alpha ! Fractional time
INTEGER :: i  ! Loop index

INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName = 'T_INT'
! ----------------------------------------------------------------------

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)

alpha = (t3-t1) / (t2-t1)

DO i=1, points

  data_t3(i) = data_t2(i)*alpha+data_t1(i)*(1-alpha)
  IF (data_t1(i) == rmdi) data_t3(i) = data_t2(i)
  IF (data_t2(i) == rmdi) data_t3(i) = data_t1(i)

END DO

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)
RETURN

END SUBROUTINE t_int

END MODULE t_int_mod
