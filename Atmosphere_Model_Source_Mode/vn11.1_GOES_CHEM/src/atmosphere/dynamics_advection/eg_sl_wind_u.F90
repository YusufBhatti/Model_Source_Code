! *****************************COPYRIGHT*******************************
! (C) Crown copyright Met Office. All rights reserved.
! For further details please refer to the file COPYRIGHT.txt
! which you should have received as part of this distribution.
! *****************************COPYRIGHT*******************************
!
!
! Subroutine Interface:
MODULE eg_sl_wind_u_mod
IMPLICIT NONE
CHARACTER(LEN=*), PARAMETER, PRIVATE :: ModuleName='EG_SL_WIND_U_MOD'

CONTAINS
SUBROUTINE eg_sl_wind_u(g_i_pe, depart_scheme, l_rk_dps,              &
                depart_order, high_order_scheme,                      &
                monotone_scheme, depart_high_order_scheme,            &
                depart_monotone_scheme,                               &
                first_constant_r_rho_level,                           &
                interp_vertical_search_tol, check_bottom_levels,      &
                l_high, l_mono,                                       &
                l_depart_high, l_depart_mono,                         &
                l_shallow, lam_max_cfl,                               &
                etadot, u_np1, v_np1, w_np1, etadot_np1,              &
                u, v, w, rwork_u, rwork_v, rwork_w,                   &
                r_u_d,error_code )


USE timestep_mod,      ONLY: timestep
USE um_parvars,        ONLY: offx, offy, halo_i, halo_j,             &
                             datastart,nproc_x,nproc_y,              &
                             at_extremity,gc_proc_col_group,         &
                             gc_proc_row_group

USE um_parcore,        ONLY: mype, nproc

USE nlsizes_namelist_mod, ONLY: global_row_length,global_rows,       &
                                row_length,rows,n_rows,model_levels

USE level_heights_mod, ONLY: eta_theta_levels, eta_rho_levels,       &
                             xi3_at_theta=>r_theta_levels,           &
                             xi3_at_rho=>r_rho_levels,               &
                             xi3_at_u=>r_at_u,                       &
                             xi3_at_v=>r_at_v

USE parkind1, ONLY: jpim, jprb       !DrHook
USE yomhook,  ONLY: lhook, dr_hook   !DrHook
USE eg_interpolation_eta_pmf_mod, ONLY: eg_interpolation_eta_pmf
USE departure_point_eta_mod, ONLY: departure_point_eta
USE eg_dep_pnt_cart_eta_mod
USE horiz_grid_mod

USE ereport_mod, ONLY: ereport
USE Field_Types
USE atm_fields_bounds_mod

USE departure_pts_mod
USE um_parparams,             ONLY: pwest, peast, pnorth, psouth
USE eg_v_at_poles_mod,        ONLY: eg_v_at_poles
USE eg_check_sl_domain_mod,   ONLY: eg_check_sl_domain
USE eg_adjust_vert_bound_mod, ONLY: eg_adjust_vert_bound

USE model_domain_mod, ONLY: model_type, mt_global
! While the following routines are not used in this module, the next
! call helps the Cray compiler to inline these routines in
! departure_point_eta. See UM ticket #3689.
USE vectlib_mod, ONLY: asin_v, atan2_v

IMPLICIT NONE
!
! Description:
!  Find u-grid departure point and apply rotation on R_u.
!
!
!
! Method: ENDGame formulation version 1.01,
!         section 7.2.
!
!
! Code Owner: Please refer to the UM file CodeOwners.txt
! This file belongs in section:  Dynamics Advection
!
! Code description:
!   Language: Fortran 90.
!   This code is written to UM programming standards version 8.3.

! Subroutine arguments

INTEGER(KIND=jpim), PARAMETER :: zhook_in  = 0
INTEGER(KIND=jpim), PARAMETER :: zhook_out = 1
REAL(KIND=jprb)               :: zhook_handle

CHARACTER(LEN=*), PARAMETER :: RoutineName='EG_SL_WIND_U'


INTEGER, INTENT(IN) :: first_constant_r_rho_level

! MPP options

INTEGER, INTENT(IN) ::                                             &
  g_i_pe(1-halo_i:global_row_length+halo_i),                       &
                     ! processor on my processor-row
                     ! holding a given value in i direction
  lam_max_cfl(2)     ! Max CFL for a LAM allowed near the
                     ! boundaries

! Integer parameters for advection

INTEGER, INTENT(IN) ::                                            &
  high_order_scheme,                                              &
                     ! a code saying which high order scheme to
                     ! use. 1 = tensor tri-cubic lagrange order
                     ! (j,i,k) no other options available at
                     ! present.
  monotone_scheme,                                                &
                     ! a code saying which monotone scheme to use.
                     ! 1 = tri-linear order (j,i,k)
                     ! no other options available at present.
  depart_scheme,                                                  &
                     ! code saying which departure point scheme to
                     ! use.
  depart_order,                                                   &
                     ! for the chosen departure point scheme how
                     ! many iterations/terms to use.
  depart_high_order_scheme,                                       &
                     ! code choosing high order
                     ! interpolation scheme used in Depart routine
  depart_monotone_scheme,                                         &
                     ! code choosing monotone
                     ! interpolation scheme used in Depart routine
  interp_vertical_search_tol,                                     &
                      ! used in interpolation code.
  check_bottom_levels ! used in interpolation code, and is
                      ! the number of levels to check to see
                      ! if the departure point lies inside the
                      ! orography.

! Logical switches for advection

LOGICAL, INTENT(IN) ::                                            &
  l_high,                                                         &
                   ! True, if high order interpolation required.
  l_mono,                                                         &
                   ! True, if interpolation required to be monotone.
  l_depart_high,                                                  &
                   ! True if high order interpolation scheme to be
                   ! used in Depart scheme
  l_depart_mono
                   ! True if monotone interpolation scheme to be
                   ! used in Depart scheme


LOGICAL, INTENT(IN) :: l_shallow, l_rk_dps

REAL, INTENT(IN) ::                                                &
  etadot(1-offx:row_length+offx,1-offy:rows+offy,0:model_levels),  &
  u(-halo_i:row_length-1+halo_i,1-halo_j:rows+halo_j,              &
         model_levels),                                            &
  v(1-halo_i:row_length+halo_i,-halo_j:n_rows-1+halo_j,            &
        model_levels),                                             &
  w(1-halo_i:row_length+halo_i, 1-halo_j:rows+halo_j,              &
         0:model_levels),                                          &
  u_np1(-offx:row_length-1+offx,1-offy:rows+offy, model_levels),   &
  v_np1(1-offx:row_length+offx,-offy:n_rows-1+offy, model_levels), &
  w_np1(1-offx:row_length+offx,1-offy:rows+offy,0:model_levels),   &
  etadot_np1(1-offx:row_length+offx,1-offy:rows+offy,              &
             0:model_levels)


! Halo-ed copies of R_u, R_v, R_w for interpolation

REAL, INTENT(IN) ::                                            &
  rwork_u(-halo_i:row_length-1+halo_i,1-halo_j:rows+halo_j,    &
           model_levels),                                      &
  rwork_v(1-halo_i:row_length+halo_i,-halo_j:n_rows-1+halo_j,  &
           model_levels),                                      &
  rwork_w(1-halo_i:row_length+halo_i,1-halo_j:rows+halo_j,     &
            0:model_levels)

INTEGER :: error_code   ! Non-zero on exit if error detected.

! Timelevel n (rotated) v-departure point quantity

REAL, INTENT(OUT) ::                                           &
  r_u_d(-offx:row_length-1+offx,1-offy:rows+offy,model_levels)

! Local variables

! row_length, number of rows and indexing offset for
! the dep point type computed

INTEGER :: dep_row_len, dep_rows, off_i, off_j, off_k, offz,   &
           number_of_inputs

INTEGER :: i, j, k

REAL    :: rm_11, rm_12, rm_13, temp

! Timelevel n R quantities interpolated on a u-point

REAL ::                                       &
  ru_ud(0:row_length-1,rows,model_levels),    &
  rv_ud(0:row_length-1,rows,model_levels),    &
  rw_ud(0:row_length-1,rows,model_levels)

REAL :: alpha
  ! Temporary local
REAL :: temp_csalpha

INTEGER :: ierr

REAL :: max_xi1, min_xi1, max_xi2, min_xi2

! End of header

! 1.0 Start of subroutine code: perform the calculation.

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_in,zhook_handle)

dep_row_len = udims%i_len
dep_rows    = udims%j_len
off_i = 1
off_j = 0
off_k = 0
offz  = 0

number_of_inputs = 1
!      alpha = alpha_u
alpha = 0.5

IF (model_type /= mt_global) THEN
  CALL eg_dep_pnt_cart_eta(                                            &
                g_i_pe,                                                &
                fld_type_u, dep_row_len, dep_rows, off_i ,off_j, off_k,&
                offz,depart_scheme, depart_order, l_rk_dps,            &
                depart_high_order_scheme,                              &
                depart_monotone_scheme, first_constant_r_rho_level,    &
                l_depart_high, l_depart_mono, alpha, eta_rho_levels,   &
                etadot, u_np1, v_np1, w_np1,                           &
                etadot_np1, u, v, w, depart_xi1_u, depart_xi2_u,       &
                depart_xi3_u )
ELSE
  CALL departure_point_eta(                                            &
                g_i_pe,                                                &
                fld_type_u, dep_row_len, dep_rows,                     &
                off_i ,off_j, off_k, offz,l_rk_dps, depart_order,      &
                depart_high_order_scheme, depart_monotone_scheme,      &
                first_constant_r_rho_level,l_depart_high,              &
                l_depart_mono, l_shallow,                              &
                alpha, eta_rho_levels,                                 &
                xi3_at_theta, xi3_at_rho, xi3_at_u, xi3_at_v,          &
                etadot, u_np1, v_np1,etadot_np1, u, v, w, depart_xi1_u,&
                depart_xi2_u,depart_xi3_u )
END IF


CALL eg_interpolation_eta_pmf(                                        &
                     eta_rho_levels,fld_type_u, number_of_inputs,     &
                     row_length, rows, model_levels, rows,            &
                     row_length, rows, model_levels,                  &
                     high_order_scheme, monotone_scheme,              &
                     l_high, l_mono, depart_xi3_u, depart_xi1_u,      &
                     depart_xi2_u, mype, nproc, nproc_x, nproc_y,     &
                     halo_i, halo_j,                                  &
                     global_row_length, datastart, at_extremity,      &
                     g_i_pe, gc_proc_row_group, gc_proc_col_group,    &
                     0, 0, error_code,                                &
                     rwork_u, ru_ud)

IF ( .NOT. cartesian_grid ) THEN
  CALL eg_interpolation_eta_pmf(                                      &
                     eta_rho_levels,fld_type_v, number_of_inputs,     &
                     row_length, n_rows, model_levels, rows,          &
                     row_length, rows, model_levels,                  &
                     high_order_scheme, monotone_scheme,              &
                     l_high, l_mono, depart_xi3_u, depart_xi1_u,      &
                     depart_xi2_u, mype, nproc, nproc_x, nproc_y,     &
                     halo_i, halo_j,                                  &
                     global_row_length, datastart, at_extremity,      &
                     g_i_pe, gc_proc_row_group, gc_proc_col_group,    &
                     0, 0, error_code,                                &
                     rwork_v, rv_ud )

  IF ( .NOT. l_shallow ) THEN
    CALL eg_interpolation_eta_pmf(                                    &
                     eta_theta_levels,fld_type_w, number_of_inputs,   &
                     row_length, rows, model_levels+1, rows,          &
                     row_length, rows, model_levels,                  &
                     high_order_scheme, monotone_scheme,              &
                     l_high, l_mono, depart_xi3_u, depart_xi1_u,      &
                     depart_xi2_u, mype, nproc, nproc_x, nproc_y,     &
                     halo_i, halo_j,                                  &
                     global_row_length, datastart, at_extremity,      &
                     g_i_pe, gc_proc_row_group, gc_proc_col_group,    &
                     0, 0, error_code,                                &
                     rwork_w, rw_ud)
  END IF
END IF

IF ( .NOT. cartesian_grid ) THEN
  IF (l_shallow) THEN

!$OMP PARALLEL DO PRIVATE(i,j,k,temp,temp_csalpha,rm_11,rm_12)        &
!$OMP& DEFAULT(NONE) SHARED(model_levels,udims,xi1_u,depart_xi1_u,    &
!$OMP& xi2_p,depart_xi2_u,r_u_d,rv_ud,ru_ud) SCHEDULE(STATIC)
    DO k=1, model_levels
      DO j=udims%j_start, udims%j_end
        DO i=udims%i_start, udims%i_end

          ! Coded for spherical case only at the moment

          temp  = SIN(xi1_u(i)-depart_xi1_u(i,j,k))
          temp_csalpha = SIN(xi2_p(j))*SIN(depart_xi2_u(i,j,k)) +       &
                         COS(xi2_p(j))*COS(depart_xi2_u(i,j,k)) *       &
                         COS(xi1_u(i)-depart_xi1_u(i,j,k))

          rm_11 = ( COS(xi2_p(j))*COS(depart_xi2_u(i,j,k)) +            &
                    COS(xi1_u(i)-depart_xi1_u(i,j,k)) *                 &
                    (1.0+SIN(xi2_p(j))*SIN(depart_xi2_u(i,j,k)))) /     &
                  (1.0 + temp_csalpha)
          rm_12 = (SIN(xi2_p(j))+SIN(depart_xi2_u(i,j,k))) * temp /     &
                  (1.0 + temp_csalpha)

          r_u_d(i,j,k) = rm_11*ru_ud(i,j,k) + rm_12*rv_ud(i,j,k)

        END DO
      END DO
    END DO
!$OMP END PARALLEL DO

  ELSE  !Else, if not L_shallow

!$OMP PARALLEL DO PRIVATE(i,j,k,temp,rm_11,rm_12,rm_13) DEFAULT(NONE) &
!$OMP& SHARED( model_levels,udims,xi1_u,depart_xi1_u,depart_xi2_u,    &
!$OMP& r_u_d,ru_ud,rv_ud,rw_ud) SCHEDULE(STATIC)
    DO k=1, model_levels
      DO j=udims%j_start, udims%j_end
        DO i=udims%i_start, udims%i_end

          ! Coded for spherical case only at the moment

          temp  = SIN(xi1_u(i)-depart_xi1_u(i,j,k))

          rm_11 = COS(xi1_u(i)-depart_xi1_u(i,j,k))
          rm_12 = SIN(depart_xi2_u(i,j,k))*temp
          rm_13 =-COS(depart_xi2_u(i,j,k))*temp

          r_u_d(i,j,k) = rm_11*ru_ud(i,j,k) +                       &
                         rm_12*rv_ud(i,j,k) +                       &
                         rm_13*rw_ud(i,j,k)

        END DO
      END DO
    END DO
!$OMP END PARALLEL DO
  END IF !End of If shallow

ELSE ! If cartesian then

!$OMP PARALLEL DO PRIVATE(i,j,k) DEFAULT(NONE) SHARED(model_levels, &
!$OMP& udims,r_u_d,ru_ud) SCHEDULE(STATIC)
  DO k=1, model_levels
    DO j=udims%j_start, udims%j_end
      DO i=udims%i_start, udims%i_end

        r_u_d(i,j,k) = ru_ud(i,j,k)

      END DO
    END DO
  END DO
!$OMP END PARALLEL DO

END IF

IF (lhook) CALL dr_hook(ModuleName//':'//RoutineName,zhook_out,zhook_handle)
RETURN
END SUBROUTINE eg_sl_wind_u


END MODULE eg_sl_wind_u_mod
