! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
! Reads the RUN_Aerosol namelist
!
MODULE rcf_readnl_runaerosol_mod

IMPLICIT NONE

! Description:
!  rcf_readnl_runaerosol reads in the RUN_Aerosol namelist.
!
! Method:
!  Data read in via unit number passed as argument.
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section: Reconfiguration
!
! Code Description:
!  Language: FORTRAN 95.
!  This code is written to UMDP3 v8.5 programming standards.

CHARACTER(LEN=*), PARAMETER, PRIVATE :: ModuleName='RCF_READNL_RUNAEROSOL_MOD'

CONTAINS

SUBROUTINE rcf_readnl_runaerosol (nft)

USE run_aerosol_mod, ONLY: RUN_Aerosol, run_aerosol_check,  &
                           print_nlist_run_aerosol,         &
                           read_nml_run_aerosol

USE umPrintMgr, ONLY:      umPrint, umMessage,  &
                           PrintStatus, PrStatus_Oper

USE UM_parcore, ONLY:      mype

USE yomhook,   ONLY: & ! DrHook
    lhook,           &
    dr_hook

USE parkind1,  ONLY: &
    jprb,            &
    jpim

IMPLICIT NONE

! Arguments
INTEGER, INTENT(IN)  :: nft  ! unit number

! Local variables
CHARACTER (LEN=*), PARAMETER :: RoutineName = 'RCF_READNL_RUNAEROSOL'
! Dr Hook
INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)
! Defaults are set in the namelist module
! Read the namelist
CALL read_nml_run_aerosol(nft)
IF ( PrintStatus >= PrStatus_Oper .AND. mype == 0) THEN
  CALL print_nlist_RUN_Aerosol()
END IF

CALL run_aerosol_check



IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName, zhook_out, zhook_handle)
RETURN
END SUBROUTINE rcf_readnl_runaerosol

END MODULE rcf_readnl_runaerosol_mod
