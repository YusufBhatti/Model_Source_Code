MODULE ukca_activ_mod
! *****************************COPYRIGHT*******************************
!
! (c) [University of Oxford] [2011]. All rights reserved.
! This routine has been licensed to the Met Office for use and
! distribution under the UKCA collaboration agreement, subject
! to the terms and conditions set out therein.
! [Met Office Ref SC138]
! *****************************COPYRIGHT*******************************
!
!  Description:  Contains subroutines for generating arrays for pdf of updraught
!
!  UKCA is a community model supported by The Met Office and
!  NCAS, with components provided by The University of Cambridge
!  University of Leeds, University of Oxford, and The Met Office.
!  See: www.ukca.ac.uk
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section: UKCA
!
!  Code Description:
!    Language:  FORTRAN 90
!
! ######################################################################
!
!  Author: Rosalind West, AOPP, Oxford, 2010
!  -------


USE yomhook,  ONLY: lhook, dr_hook
USE parkind1, ONLY: jprb, jpim
USE nlsizes_namelist_mod, ONLY: model_levels
IMPLICIT NONE

CHARACTER(LEN=*), PARAMETER, PRIVATE :: ModuleName='UKCA_ACTIV_MOD'

CONTAINS

SUBROUTINE activmklin(kbdim, arrmin, arrmax, nbins, binwidth, &
                      linarr)

IMPLICIT NONE

INTEGER, INTENT(IN)  :: kbdim
INTEGER, INTENT(IN)  :: nbins
REAL,    INTENT(IN)  :: arrmin(kbdim, model_levels)
REAL,    INTENT(IN)  :: arrmax(kbdim, model_levels)
REAL,    INTENT(OUT) :: binwidth(kbdim, model_levels, nbins)
REAL,    INTENT(OUT) :: linarr(kbdim, model_levels, nbins)

INTEGER :: i,j,k
INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName='ACTIVMKLIN'

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)

DO k = 1, nbins
  DO i=1, model_levels
    DO j=1, kbdim
      binwidth(j,i,k)=(arrmax(j,i)-arrmin(j,i))/REAL(nbins)
      linarr(j,i,k)= arrmin(j,i) + (REAL(k)-0.5)*binwidth(j,i,k)
    END DO
  END DO
END DO

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)
RETURN
END SUBROUTINE activmklin
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
SUBROUTINE activmkpdf (kbdim, array, nbins, sigma, mean,    &
                       pdfarr)

USE conversions_mod, ONLY: pi

IMPLICIT NONE

INTEGER, INTENT(IN) :: kbdim
INTEGER, INTENT(IN) :: nbins
REAL,    INTENT(IN) :: array(kbdim, model_levels, nbins)
REAL,    INTENT(IN) :: sigma(kbdim, model_levels)
REAL,    INTENT(IN) :: mean(kbdim, model_levels)
REAL,    INTENT(OUT) :: pdfarr(kbdim, model_levels, nbins)

INTEGER :: i, j, k
INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName='ACTIVMKPDF'

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)

DO k=1, nbins
  DO i=1, model_levels
    DO j=1, kbdim
         ! normalised gaussian
      pdfarr(j,i,k) = (1.0/((2.0*pi)**0.5))*(1.0/sigma(j,i))*    &
            EXP(-((array(j,i,k)-mean(j,i))**2/(2*sigma(j,i)**2)))
    END DO
  END DO
END DO

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)

RETURN
END SUBROUTINE activmkpdf
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
SUBROUTINE activmkskew (kbdim, array, nbins, sigma, mean,   &
                        alpha, pdfarr)

USE conversions_mod, ONLY: pi
USE vectlib_mod, ONLY: exp_v
USE umErf_mod, ONLY: umErf

IMPLICIT NONE

INTEGER, INTENT(IN) :: kbdim
INTEGER, INTENT(IN) :: nbins
REAL,    INTENT(IN) :: array(kbdim, model_levels, nbins)
REAL,    INTENT(IN) :: sigma(kbdim, model_levels)
REAL,    INTENT(IN) :: mean(kbdim, model_levels)
REAL,    INTENT(IN) :: alpha(kbdim, model_levels)
REAL,    INTENT(OUT) :: pdfarr(kbdim, model_levels, nbins)

REAL                :: tmp1(kbdim, model_levels, nbins)
REAL                :: tmp1_out(kbdim, model_levels, nbins)

INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName='ACTIVMKSKEW'
INTEGER :: i, j, k

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)
DO i=1, model_levels
  DO j=1, kbdim
    DO k=1, nbins
      tmp1(j,i,k)= -((array(j,i,k)-mean(j,i))**2/(2*sigma(j,i)**2))
    END DO
  END DO
END DO
CALL exp_v(model_levels*kbdim*nbins,tmp1,tmp1_out)
DO i=1, model_levels
  DO j=1, kbdim
    DO k=1, nbins
      ! skew-normal distribution
      pdfarr(j,i,k)=(1.0/((2.0*pi)**0.5))*(1.0/sigma(j,i))*     &
          tmp1_out(j,i,k) *        &
          (1+umErf(alpha(j,i)*(array(j,i,k)-mean(j,i))*            &
          (1.0/((2.0)**0.5))*(1.0/sigma(j,i))))
    END DO
  END DO
END DO

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)

RETURN
END SUBROUTINE activmkskew
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
SUBROUTINE activclosest (arrayin, nbins, VALUE, closeval,         &
                         closeind)

IMPLICIT NONE

INTEGER, INTENT(IN)  :: nbins
REAL,    INTENT(IN)  :: arrayin(nbins)
REAL,    INTENT(IN)  :: VALUE
INTEGER, INTENT(OUT) :: closeind
REAL,    INTENT(OUT) :: closeval

INTEGER :: min_subs(1)
REAL    :: subarr(nbins)
INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName='ACTIVCLOSEST'


IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)

! Subtract the value you wish to compare from
! the whole array you are comparing it to and
! create a new array of these differences.
subarr(:) = arrayin(:) - VALUE

! Find the smallest absolute difference between value and array.
! *min_subs contains the location of the smallest absolute value of subarr
!  NB the value of MINLOC must be returned to an array.
! E.g. "icmin=minloc(c(1:3))" will only work if "icmin" has been
! declared to be an integer array, and the value "3" will be placed
! in the first element of "icmin".

min_subs = MINLOC(ABS(subarr(1:nbins)))

! *closeind is just an integer of the 1st element of min_subs
closeind = min_subs(1)

! *closeval contains the value of the closest element of arrayin to value
! *closest contains the location of that value
closeval = arrayin(closeind)

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)

RETURN
END SUBROUTINE activclosest


END MODULE ukca_activ_mod
