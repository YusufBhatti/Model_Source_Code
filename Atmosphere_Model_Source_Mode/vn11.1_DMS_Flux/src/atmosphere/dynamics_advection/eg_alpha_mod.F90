! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section: Dynamics

MODULE eg_alpha_mod

IMPLICIT NONE

REAL, SAVE :: alpha_u        = 0.55
REAL, SAVE :: alpha_v        = 0.55
REAL, SAVE :: alpha_w        = 0.55
REAL, SAVE :: alpha_rho      = 0.55
REAL, SAVE :: alpha_p
REAL, SAVE :: alpha_theta    = 0.55

REAL, SAVE :: tau_u        = 0.55
REAL, SAVE :: tau_v        = 0.55
REAL, SAVE :: tau_w        = 0.55
REAL, SAVE :: tau_rho      = 0.55
REAL, SAVE :: tau_p
REAL, SAVE :: tau_theta    = 0.55

LOGICAL, SAVE :: alpha_changed = .FALSE.

END MODULE
