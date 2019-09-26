! (C) Copyright 2018-2019 UCAR
!
! This software is licensed under the terms of the Apache Licence Version 2.0
! which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

module moisture_vt_mod

use fv3jedi_kinds_mod, only: kind_real
use fv3jedi_geom_mod, only: fv3jedi_geom
use fv3jedi_constants_mod, only: rdry,grav,tice,zvir

use pressure_vt_mod, only: delp_to_pe_p_logp

implicit none
private

public crtm_ade_efr
public crtm_mixratio
public crtm_mixratio_tl
public crtm_mixratio_ad
public rh_to_q
public rh_to_q_tl
public rh_to_q_ad
public q_to_rh
public q_to_rh_tl
public q_to_rh_ad
public get_qsat

contains

!>----------------------------------------------------------------------------
!> Compute cloud area density and effective radius for the crtm --------------
!>----------------------------------------------------------------------------

subroutine crtm_ade_efr( geom,p,T,delp,sea_frac,q,ql,qi,ql_ade,qi_ade,ql_efr,qi_efr)

implicit none

!Arguments
type(fv3jedi_geom)  , intent(in)  :: geom
real(kind=kind_real), intent(in)  :: p(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)     !Pressure | Pa
real(kind=kind_real), intent(in)  :: t(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)     !Temperature | K
real(kind=kind_real), intent(in)  :: delp(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Layer thickness | Pa
real(kind=kind_real), intent(in)  :: sea_frac(geom%isc:geom%iec,geom%jsc:geom%jec)          !Sea fraction | 1
real(kind=kind_real), intent(in)  :: q(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)     !Specific humidity | kg/kg
real(kind=kind_real), intent(in)  :: ql(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)    !Mixing ratio of cloud liquid water | kg/kg
real(kind=kind_real), intent(in)  :: qi(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)    !Mixing ratio of cloud ice water | kg/kg

real(kind=kind_real), intent(out) :: ql_ade(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz) !area density for cloud liquid water | kg/m^2
real(kind=kind_real), intent(out) :: qi_ade(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz) !area density for cloud ice water | kg/m^2
real(kind=kind_real), intent(out) :: ql_efr(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz) !efr for cloud liquid water | microns
real(kind=kind_real), intent(out) :: qi_efr(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz) !efr for cloud ice | microns

!Locals
integer :: isc,iec,jsc,jec,npz
integer :: i,j,k
logical, allocatable :: seamask(:,:)
real(kind=kind_real) :: tem1, tem2, tem3, kgkg_to_kgm2


! Grid convenience
! ----------------
isc = geom%isc
iec = geom%iec
jsc = geom%jsc
jec = geom%jec
npz = geom%npz


! Set outputs to zero
! -------------------
ql_ade = 0.0_kind_real
qi_ade = 0.0_kind_real
ql_efr = 0.0_kind_real
qi_efr = 0.0_kind_real


! Sea mask
! --------
allocate(seamask(isc:iec,jsc:jec))
seamask = .false.
do j = jsc,jec
  do i = isc,iec
     seamask(i,j) = min(max(0.0_kind_real,sea_frac(i,j)),1.0_kind_real)  >= 0.99_kind_real
  enddo
enddo


! Convert clouds from kg/kg into kg/m^2
! -------------------------------------
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec
       if (seamask(i,j)) then

         kgkg_to_kgm2 = delp(i,j,k) / grav
         ql_ade(i,j,k) = max(ql(i,j,k),0.0_kind_real) * kgkg_to_kgm2
         qi_ade(i,j,k) = max(qi(i,j,k),0.0_kind_real) * kgkg_to_kgm2

         if (t(i,j,k) - tice > -20.0_kind_real) then
            ql_ade(i,j,k) = max(1.001_kind_real*1.0E-6_kind_real,ql_ade(i,j,k))
         endif

         if (t(i,j,k) < tice) then
            qi_ade(i,j,k) = max(1.001_kind_real*1.0E-6_kind_real,qi_ade(i,j,k))
         endif

       endif
    enddo
  enddo
enddo

! Cloud liquid water effective radius
! -----------------------------------
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec
       if (seamask(i,j)) then
         tem1 = max(0.0_kind_real,(tice-t(i,j,k))*0.05_kind_real)
         ql_efr(i,j,k) = 5.0_kind_real + 5.0_kind_real * min(1.0_kind_real, tem1)
       endif
    enddo
  enddo
enddo


! Cloud ice water effective radius
! ---------------------------------
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec

      if (seamask(i,j)) then

        tem2 = t(i,j,k) - tice
        tem1 = grav/rdry
        tem3 = tem1 * qi_ade(i,j,k) * (p(i,j,k)/delp(i,j,k))/t(i,j,k) * (1.0_kind_real + zvir * max(q(i,j,k),0.0_kind_real))

        if (tem2 < -50.0_kind_real ) then
           qi_efr(i,j,k) =  (1250._kind_real/9.917_kind_real)*tem3**0.109_kind_real
        elseif (tem2 < -40.0_kind_real ) then
           qi_efr(i,j,k) =  (1250._kind_real/9.337_kind_real)*tem3**0.08_kind_real
        elseif (tem2 < -30.0_kind_real ) then
           qi_efr(i,j,k) =  (1250._kind_real/9.208_kind_real)*tem3**0.055_kind_real
        else
           qi_efr(i,j,k) =  (1250._kind_real/9.387_kind_real)*tem3**0.031_kind_real
        endif

      endif

    enddo
  enddo
enddo


ql_ade = max(0.0_kind_real,ql_ade)
qi_ade = max(0.0_kind_real,qi_ade)
ql_efr = max(0.0_kind_real,ql_efr)
qi_efr = max(0.0_kind_real,qi_efr)

deallocate(seamask)

end subroutine crtm_ade_efr

!----------------------------------------------------------------------------
! Compute mixing ratio from specific humidity -------------------------------
!----------------------------------------------------------------------------

subroutine crtm_mixratio(geom,q,qmr)

implicit none

!Arguments
type(fv3jedi_geom)  , intent(in ) :: geom
real(kind=kind_real), intent(in ) :: q  (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Specific humidity | kg/kg
real(kind=kind_real), intent(out) :: qmr(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Mixing ratio | 1

!Locals
integer :: isc,iec,jsc,jec,npz
integer :: i,j,k
real(kind=kind_real) :: q_pos(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: c3(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)


! Grid convenience
! ----------------
isc = geom%isc
iec = geom%iec
jsc = geom%jsc
jec = geom%jec
npz = geom%npz


! Remove negative values
! ----------------------
q_pos = q
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec
      if (q_pos(i,j,k) < 0.0_kind_real) then
        q_pos(i,j,k) = 0.0_kind_real
      endif
    enddo
  enddo
enddo


! Convert specific humidity
! -------------------------
c3 = 1.0_kind_real / (1.0_kind_real - q_pos)
qmr = 1000.0_kind_real * q_pos * c3

end subroutine crtm_mixratio

!----------------------------------------------------------------------------

subroutine crtm_mixratio_tl(geom,q,q_tl,qmr_tl)

implicit none

!Arguments
type(fv3jedi_geom)  , intent(in ) :: geom
real(kind=kind_real), intent(in ) :: q     (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Specific humidity | kg/kg
real(kind=kind_real), intent(in ) :: q_tl  (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Specific humidity | kg/kg
real(kind=kind_real), intent(out) :: qmr_tl(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Mixing ratio | 1

!Locals
integer :: isc,iec,jsc,jec,npz
integer :: i,j,k
real(kind=kind_real) :: q_pos(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: q_tl_pos(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: c3   (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: c3_tl(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)


! Grid convenience
! ----------------
isc = geom%isc
iec = geom%iec
jsc = geom%jsc
jec = geom%jec
npz = geom%npz


! Remove negative values
! ----------------------
q_pos = q
q_tl_pos = q_tl
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec
      if (q_pos(i,j,k) < 0.0_kind_real) then
        q_pos(i,j,k) = 0.0_kind_real
        q_tl_pos(i,j,k) = 0.0_kind_real
      endif
    enddo
  enddo
enddo


! Convert specific humidity
! -------------------------
c3 = 1.0_kind_real / (1.0_kind_real - q_pos)
c3_tl = -((-q_tl_pos)/(1.0_kind_real-q_pos)**2)
qmr_tl = 1000.0_kind_real*(q_tl_pos*c3+q_pos*c3_tl)

end subroutine crtm_mixratio_tl

!----------------------------------------------------------------------------

subroutine crtm_mixratio_ad(geom,q,q_ad,qmr_ad)

implicit none

!Arguments
type(fv3jedi_geom)  , intent(in )   :: geom
real(kind=kind_real), intent(in )   :: q     (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Specific humidity | kg/kg
real(kind=kind_real), intent(inout) :: q_ad  (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Specific humidity | kg/kg
real(kind=kind_real), intent(inout) :: qmr_ad(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)  !Mixing ratio | 1

!Locals
integer :: isc,iec,jsc,jec,npz
integer :: i,j,k
real(kind=kind_real) :: q_pos(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: q_ad_pos(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: c3   (geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)
real(kind=kind_real) :: c3_ad(geom%isc:geom%iec,geom%jsc:geom%jec, 1:geom%npz)


! Grid convenience
! ----------------
isc = geom%isc
iec = geom%iec
jsc = geom%jsc
jec = geom%jec
npz = geom%npz


! Remove negative values
! ----------------------
q_pos = q
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec
      if (q_pos(i,j,k) < 0.0_kind_real) then
        q_pos(i,j,k) = 0.0_kind_real
      endif
    enddo
  enddo
enddo


! Convert specific humidity
! -------------------------
c3 = 1.0_kind_real/(1.0_kind_real-q_pos)
c3_ad = 1000.0_kind_real*q_pos*qmr_ad
q_ad_pos = c3_ad/(1.0_kind_real-q_pos)**2 + 1000.0_kind_real*c3*qmr_ad
qmr_ad = 0.0_8


! Remove negative values adjoint
! ------------------------------
do k = 1,npz
  do j = jsc,jec
    do i = isc,iec
      if (q_pos(i,j,k) < 0.0_kind_real) then
        q_ad_pos(i,j,k) = 0.0_kind_real
      endif
    enddo
  enddo
enddo

q_ad = q_ad + q_ad_pos

end subroutine crtm_mixratio_ad


!----------------------------------------------------------------------------
! Relative to specific humidity ---------------------------------------------
!----------------------------------------------------------------------------

subroutine rh_to_q(geom,qsat,rh,q)

 implicit none
 type(fv3jedi_geom),   intent(in)    :: geom
 real(kind=kind_real), intent(in)    :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::   rh(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

 q = rh * qsat

end subroutine rh_to_q

!----------------------------------------------------------------------------

subroutine rh_to_q_tl(geom,qsat,rh,q)

 implicit none
 type(fv3jedi_geom),   intent(in)    :: geom
 real(kind=kind_real), intent(in)    :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(in)    ::   rh(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

 q = rh * qsat

end subroutine rh_to_q_tl

!----------------------------------------------------------------------------

subroutine rh_to_q_ad(geom,qsat,rh,q)

 implicit none
 type(fv3jedi_geom),   intent(in)    :: geom
 real(kind=kind_real), intent(in)    :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(in)    ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::   rh(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

 rh = rh + q * qsat

end subroutine rh_to_q_ad


!----------------------------------------------------------------------------
! Specific to relative humidity ---------------------------------------------
!----------------------------------------------------------------------------

subroutine q_to_rh(geom,qsat,q,rh)

 implicit none
 type(fv3jedi_geom),   intent(in)    :: geom
 real(kind=kind_real), intent(in)    :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(in)    ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::   rh(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

 rh = q / qsat

end subroutine q_to_rh

!----------------------------------------------------------------------------

subroutine q_to_rh_tl(geom,qsat,q,rh)

 implicit none
 type(fv3jedi_geom),   intent(in)    :: geom
 real(kind=kind_real), intent(in)    :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(in)    ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::   rh(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

 rh = q / qsat

end subroutine q_to_rh_tl

!----------------------------------------------------------------------------

subroutine q_to_rh_ad(geom,qsat,q,rh)

 implicit none
 type(fv3jedi_geom),   intent(in)    :: geom
 real(kind=kind_real), intent(in)    :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(inout) ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
 real(kind=kind_real), intent(in)    ::   rh(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

 q = q + rh / qsat

end subroutine q_to_rh_ad

!----------------------------------------------------------------------------

subroutine get_qsat(geom,delp,t,q,qsat)

  implicit none
  type(fv3jedi_geom),   intent(in)  :: geom
  real(kind=kind_real), intent(in)  :: delp(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
  real(kind=kind_real), intent(in)  ::    t(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
  real(kind=kind_real), intent(in)  ::    q(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)
  real(kind=kind_real), intent(out) :: qsat(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz)

  integer :: i,j
  real(kind=kind_real), allocatable :: pe(:,:,:)
  real(kind=kind_real), allocatable :: pm(:,:,:)

  allocate(pe(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz+1))
  allocate(pm(geom%isc:geom%iec,geom%jsc:geom%jec,1:geom%npz  ))

  call delp_to_pe_p_logp(geom,delp,pe,pm)

  do j = geom%jsc,geom%jec
    do i = geom%isc,geom%iec
      call qsmith(geom%npz,t(i,j,:),q(i,j,:),pm(i,j,:),qsat(i,j,:))
    enddo
  enddo

  deallocate(pm)
  deallocate(pe)

end subroutine get_qsat

!----------------------------------------------------------------------------

subroutine qsmith(nlev,t,sphum,pl,qs)

  implicit none
  integer,         intent(in)  :: nlev
  real(kind_real), intent(in)  :: t(nlev)
  real(kind_real), intent(in)  :: sphum(nlev)
  real(kind_real), intent(in)  :: pl(nlev)
  real(kind_real), intent(out) :: qs(nlev)

  real(kind_real), parameter :: esl = 0.621971831
  real(kind_real), allocatable :: table(:), des(:)

  real(kind_real) :: es
  real(kind_real) :: ap1, eps10
  integer :: k, it
  integer, parameter :: length=2621

  eps10  = 10.0_kind_real*esl

  allocate ( table(length) )
  call qs_table(length,table)

  allocate (  des (length) )
  do k=1,length-1
    des(k) = table(k+1) - table(k)
  enddo
  des(length) = des(length-1)

  do k=1,nlev
    ap1 = 10.0_kind_real*dim(t(k), tice-160.0_kind_real) + 1.0_kind_real
    ap1 = min(2621.0_kind_real, ap1)
    it = int(ap1)
    es = table(it) + (ap1-it)*des(it)
    qs(k) = esl*es*(1.0_kind_real+zvir*sphum(k))/(pl(k))
  enddo

  deallocate(table,des)

end subroutine qsmith

!----------------------------------------------------------------------------

subroutine qs_table(n,table)

  implicit none

  integer,              intent(in)    :: n
  real(kind=kind_real), intent(inout) :: table(n)

  real(kind=kind_real) :: tem, aa, b, c, d, e
  integer :: i
  real(kind=kind_real), parameter :: dt=0.1_kind_real
  real(kind=kind_real), parameter :: esbasw = 1013246.0_kind_real
  real(kind=kind_real), parameter :: tbasw = 373.16_kind_real
  real(kind=kind_real), parameter :: tbasi = 273.16_kind_real
  real(kind=kind_real), parameter :: Tmin = tbasi - 160.0_kind_real

  ! Compute es over water, see smithsonian meteorological tables page 350.
  do  i=1,n
     tem = tmin+dt*real(i-1)
     aa  = -7.90298_kind_real*(tbasw/tem-1)
     b   =  5.02808_kind_real*log10(tbasw/tem)
     c   = -1.3816e-07_kind_real*(10.0_kind_real**((1.0_kind_real-tem/tbasw)*11.344_kind_real)-1.0_kind_real)
     d   =  8.1328e-03_kind_real*(10.0_kind_real**((tbasw/tem-1.0_kind_real)*(-3.49149_kind_real))-1.0_kind_real)
     e   =  log10(esbasw)
     table(i)  = 0.1_kind_real*10.0_kind_real**(aa+b+c+d+e)
  enddo

end subroutine qs_table

!----------------------------------------------------------------------------

end module moisture_vt_mod
