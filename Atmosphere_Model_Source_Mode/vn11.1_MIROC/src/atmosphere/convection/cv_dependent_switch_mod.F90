! *****************************COPYRIGHT**************************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT**************************************
!
!  Global data module for switches/options concerned with convection.

MODULE cv_dependent_switch_mod
USE missing_data_mod, ONLY: imdi, rmdi 

IMPLICIT NONE
SAVE

! Description:
!   Module containing extra switches set dependent on convection
!   namelist variables read in at the start of the model.
!
! Method:
!   The values of the variables are overriden by a call to the routine
!   cv_set_dependent_switches called from readlsta or scm_shell after
!   reading in namelists. Doing this should save CPU as the switches
!   will not be set under if tests each call to e.g. layer_cn or glue_conv
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section: Convection
!
! Code description:
!   Language: Fortran 90.
!   This code is written to UM programming standards version 8.1.
!
!------------------------------------------------------------------------------

! Declarations:
!  Giving default values of switches.
!
!------------------------------------------------------------------------------
! Extra switches controlling entrainment and detrainment in layer_cn
! Used by 5A code only at present
!------------------------------------------------------------------------------

LOGICAL :: l_var_entrain = .FALSE.  ! use new variable entrainment

LOGICAL :: l_new_det     = .FALSE.  ! use new detrainment relationship

LOGICAL :: l_const_ent   = .FALSE.  ! Possible future use - no height dependence

LOGICAL :: l_rh_dep      = .FALSE.  ! Possible future use RH dependence


!------------------------------------------------------------------------------
! Extra switches controlling adaptive forced detrainment options
!------------------------------------------------------------------------------

! Shallow convection controls 0 off 1 on

INTEGER ::            &
  sh_on       = 0     & ! Flag for adaptive applied to shallow conv
 ,mdet_sh_on  = 0     & ! Flag for adaptive mixing detrainment
 ,sh_ent_on   = 0     & ! Flag for adaptive applied to entrainment
 ,sh_sdet_on  = 0     & ! Flag for smoothed forced detrainment
 ,sh_new_termc= 0       ! Flag for new termination condition

! Deep convection controls 0 off 1 on

INTEGER ::            &
  dp_on       = 0     & ! Flag for adaptive applied to deep conv
 ,mdet_dp_on  = 0     & ! Flag for adaptive mixing detrainment
 ,dp_ent_on   = 0     & ! Flag for adaptive applied to entrainment
 ,dp_sdet_on  = 0     & ! Flag for smoothed forced detrainment
 ,dp_new_termc= 0       ! Flag for new termination condition

! Congestus convection controls 0 off 1 on (5A convection only)

INTEGER ::            &
  cg_on       = 0     & ! Flag for adaptive applied to deep conv
 ,mdet_cg_on  = 0     & ! Flag for adaptive mixing detrainment
 ,cg_ent_on   = 0     & ! Flag for adaptive applied to entrainment
 ,cg_sdet_on  = 0     & ! Flag for smoothed forced detrainment
 ,cg_new_termc= 0       ! Flag for new termination condition

! Mid-level convection controls 0 off 1 on

INTEGER ::            &
  md_on       = 0     & ! Flag for adaptive applied to deep conv
 ,mdet_md_on  = 0     & ! Flag for adaptive mixing detrainment
 ,md_ent_on   = 0     & ! Flag for adaptive applied to entrainment
 ,md_sdet_on  = 0     & ! Flag for smoothed forced detrainment
 ,md_new_termc= 0       ! Flag for new termination condition

INTEGER :: cor_method = imdi !Flag for method of energy correction for 6a only

!------------------------------------------------------------------------------

END MODULE cv_dependent_switch_mod
