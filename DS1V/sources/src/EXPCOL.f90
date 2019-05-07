!
!********************************************************************
!
MODULE EXPCOL
!
! number of polynomials
INTEGER,PARAMETER :: NT = 10
REAL(8) :: gauss_w(2*NT), gauss_x(2*NT), gx(NT), gw(NT)
! exponential collision model
TYPE :: EXPparType
  INTEGER :: sp1, sp2
  REAL(8) :: alpha, A
  REAL(8) :: totxsecpar(3)
  ! sigma_ref (A^2), Et_ref(eV), alpha
  REAL(8) :: collrate(3)
  ! sigma_Tref (A^2), Tref, beta
END TYPE EXPparType
TYPE(EXPparType),target :: EXPpar(14)
INTEGER, ALLOCATABLE :: EXPCOLPair(:,:)

! variable shared between functions
INTEGER :: temp_int(1)
real(8) :: temp_real(4)
real(8) :: brent_share(2)
!$OMP THREADPRIVATE (temp_int,temp_real,brent_share)


INTERFACE EXPCOL_POT
  module procedure EXPCOL_POT_IPAIR
  module procedure EXPCOL_POT_LSMS
END INTERFACE EXPCOL_POT

contains
  subroutine EXPCOL_INIT()
    USE GAS, only: GASCODE, MSP, INONVHS
    implicit none
    integer :: i

    call cgqf(2*NT, 2, 1.0d0, 1.0d0, -1.0d0, 1.0d0, gauss_x, gauss_w)
    do i = NT+1,2*NT
      ! only take all points with x > 0
      gx(i-NT) = gauss_x(i)
      gw(i-NT) = gauss_w(i)
    end do

    IF (GASCODE .ne. 8) THEN
      STOP "Only gascode = 8 works with EXPCOL model"
    END IF
    ALLOCATE(EXPCOLPair(MSP,MSP))
    EXPCOLPair = 0
    ! The following data is generated by python script

    ! Xsec =totxsecpar(1)*exp(1-(Et/totxsecpar(2))^totxsecpar(3)) ! A^2
    ! Rate = sqrt(8*k*T/pi/mr)*collrate(1)*1e-20*(T/collrate(2))^collrate(3) !si
    ! Chimin = 0.01
    !N2-N2  SSE: 1.936326e-03
    EXPCOLPair(1,1) = 1
    INONVHS(1,1) = 2
    EXPpar(1)%sp1 = 1; EXPpar(1)%sp2 = 1
    EXPpar(1)%alpha = 4.000000d+00
    EXPpar(1)%A = 1.730000d+03
    EXPpar(1)%totxsecpar = (/1.108965402524672d+02, 3.469289960850913d-05, 7.337481454465793d-02/)
    EXPpar(1)%collrate = (/6.031917182736213d+01, 2.730000d+02, -1.539707435807606d-01/)

    !N2-N  SSE: 2.599187e-03
    EXPCOLPair(1,2) = 2; EXPCOLPair(2,1) = 2
    INONVHS(1,2) = 2; INONVHS(2,1) = 2
    EXPpar(2)%sp1 = 1; EXPpar(2)%sp2 = 2
    EXPpar(2)%alpha = 3.310000d+00
    EXPpar(2)%A = 6.200000d+02
    EXPpar(2)%totxsecpar = (/1.476325832269978d+02, 3.702873573199604d-05, 7.715327784323149d-02/)
    EXPpar(2)%collrate = (/7.829228722675090d+01, 2.730000d+02, -1.677368756104592d-01/)

    !N2-O2  SSE: 1.513185e-03
    EXPCOLPair(1,3) = 3; EXPCOLPair(3,1) = 3
    INONVHS(1,3) = 2; INONVHS(3,1) = 2
    EXPpar(3)%sp1 = 1; EXPpar(3)%sp2 = 3
    EXPpar(3)%alpha = 4.400000d+00
    EXPpar(3)%A = 4.816000d+03
    EXPpar(3)%totxsecpar = (/1.048620156743607d+02, 1.798354709647816d-05, 6.824167617837457d-02/)
    EXPpar(3)%collrate = (/5.575141908211916d+01, 2.730000d+02, -1.423487922207107d-01/)

    !N2-O  SSE: 1.087655e-03
    EXPCOLPair(1,4) = 4; EXPCOLPair(4,1) = 4
    INONVHS(1,4) = 2; INONVHS(4,1) = 2
    EXPpar(4)%sp1 = 1; EXPpar(4)%sp2 = 4
    EXPpar(4)%alpha = 5.120000d+00
    EXPpar(4)%A = 1.135000d+04
    EXPpar(4)%totxsecpar = (/9.096749726793419d+01, 4.869123716800271d-06, 6.262061005334335d-02/)
    EXPpar(4)%collrate = (/4.502972355074449d+01, 2.730000d+02, -1.339051506497571d-01/)

    !N2-NO  SSE: 1.786351e-03
    EXPCOLPair(1,5) = 5; EXPCOLPair(5,1) = 5
    INONVHS(1,5) = 2; INONVHS(5,1) = 2
    EXPpar(5)%sp1 = 1; EXPpar(5)%sp2 = 5
    EXPpar(5)%alpha = 3.610000d+00
    EXPpar(5)%A = 5.780000d+03
    EXPpar(5)%totxsecpar = (/1.603035494740292d+02, 1.487516113109594d-05, 6.720251613387863d-02/)
    EXPpar(5)%collrate = (/8.444141328736215d+01, 2.730000d+02, -1.404621966374895d-01/)

    !NO-N2  SSE: 1.786351e-03
    EXPCOLPair(5,1) = 6; EXPCOLPair(1,5) = 6
    INONVHS(5,1) = 2; INONVHS(1,5) = 2
    EXPpar(6)%sp1 = 5; EXPpar(6)%sp2 = 1
    EXPpar(6)%alpha = 3.610000d+00
    EXPpar(6)%A = 5.780000d+03
    EXPpar(6)%totxsecpar = (/1.603035494740292d+02, 1.487516113109594d-05, 6.720251613387863d-02/)
    EXPpar(6)%collrate = (/8.444141328736215d+01, 2.730000d+02, -1.404621966374895d-01/)

    !N-O2  SSE: 1.562436e-03
    EXPCOLPair(2,3) = 7; EXPCOLPair(3,2) = 7
    INONVHS(2,3) = 2; INONVHS(3,2) = 2
    EXPpar(7)%sp1 = 2; EXPpar(7)%sp2 = 3
    EXPpar(7)%alpha = 4.130000d+00
    EXPpar(7)%A = 3.870000d+03
    EXPpar(7)%totxsecpar = (/1.224074399279982d+02, 1.003490054045850d-05, 6.722320553061110d-02/)
    EXPpar(7)%collrate = (/6.181374535721175d+01, 2.730000d+02, -1.446790112112838d-01/)

    !N-O  SSE: 2.686566e-03
    EXPCOLPair(2,4) = 8; EXPCOLPair(4,2) = 8
    INONVHS(2,4) = 2; INONVHS(4,2) = 2
    EXPpar(8)%sp1 = 2; EXPpar(8)%sp2 = 4
    EXPpar(8)%alpha = 3.410000d+00
    EXPpar(8)%A = 3.480000d+02
    EXPpar(8)%totxsecpar = (/1.316637641550902d+02, 3.880240032574826d-05, 7.949989117481158d-02/)
    EXPpar(8)%collrate = (/6.884919431939926d+01, 2.730000d+02, -1.766489982630202d-01/)

    !N-NO  SSE: 1.458033e-03
    EXPCOLPair(2,5) = 9; EXPCOLPair(5,2) = 9
    INONVHS(2,5) = 2; INONVHS(5,2) = 2
    EXPpar(9)%sp1 = 2; EXPpar(9)%sp2 = 5
    EXPpar(9)%alpha = 4.210000d+00
    EXPpar(9)%A = 5.333000d+03
    EXPpar(9)%totxsecpar = (/1.232123873530758d+02, 7.628904920421630d-06, 6.562708422213186d-02/)
    EXPpar(9)%collrate = (/6.156096900534855d+01, 2.730000d+02, -1.412881406811927d-01/)

    !O2-O2  SSE: 4.190829e-03
    EXPCOLPair(3,3) = 10
    INONVHS(3,3) = 2
    EXPpar(10)%sp1 = 3; EXPpar(10)%sp2 = 3
    EXPpar(10)%alpha = 3.000000d+00
    EXPpar(10)%A = 1.500000d+02
    EXPpar(10)%totxsecpar = (/1.296542066319968d+02, 2.880019600775391d-04, 9.237037342416524d-02/)
    EXPpar(10)%collrate = (/8.016374444239321d+01, 2.730000d+02, -1.915171136304186d-01/)

    !O2-O  SSE: 1.171944e-03
    EXPCOLPair(3,4) = 11; EXPCOLPair(4,3) = 11
    INONVHS(3,4) = 2; INONVHS(4,3) = 2
    EXPpar(11)%sp1 = 3; EXPpar(11)%sp2 = 4
    EXPpar(11)%alpha = 4.850000d+00
    EXPpar(11)%A = 1.025000d+04
    EXPpar(11)%totxsecpar = (/9.951590682855550d+01, 5.692579541963022d-06, 6.324129325432543d-02/)
    EXPpar(11)%collrate = (/4.966098086155651d+01, 2.730000d+02, -1.348555376875622d-01/)

    !O2-NO  SSE: 1.654062e-03
    EXPCOLPair(3,5) = 12; EXPCOLPair(5,3) = 12
    INONVHS(3,5) = 2; INONVHS(5,3) = 2
    EXPpar(12)%sp1 = 3; EXPpar(12)%sp2 = 5
    EXPpar(12)%alpha = 3.780000d+00
    EXPpar(12)%A = 7.620000d+03
    EXPpar(12)%totxsecpar = (/1.503281779683470d+02, 1.359491686241912d-05, 6.621074535037808d-02/)
    EXPpar(12)%collrate = (/7.928364230886348d+01, 2.730000d+02, -1.376993946555516d-01/)

    !O-NO  SSE: 1.703327e-03
    EXPCOLPair(4,5) = 13; EXPCOLPair(5,4) = 13
    INONVHS(4,5) = 2; INONVHS(5,4) = 2
    EXPpar(13)%sp1 = 4; EXPpar(13)%sp2 = 5
    EXPpar(13)%alpha = 3.950000d+00
    EXPpar(13)%A = 3.140000d+03
    EXPpar(13)%totxsecpar = (/1.289010496088486d+02, 1.323024590712660d-05, 6.858591898060508d-02/)
    EXPpar(13)%collrate = (/6.606372768214798d+01, 2.730000d+02, -1.469800246259848d-01/)

    !NO-NO  SSE: 2.317134e-03
    EXPCOLPair(5,5) = 14
    INONVHS(5,5) = 2
    EXPpar(14)%sp1 = 5; EXPpar(14)%sp2 = 5
    EXPpar(14)%alpha = 3.260000d+00
    EXPpar(14)%A = 2.160000d+03
    EXPpar(14)%totxsecpar = (/1.706993947811005d+02, 3.309947693741349d-05, 7.250087309058581d-02/)
    EXPpar(14)%collrate = (/9.308534296406670d+01, 2.730000d+02, -1.512897172662553d-01/)



  end subroutine EXPCOL_INIT

  subroutine EXPCOL_END()
    implicit none
    deallocate(EXPCOLPair)
  end subroutine EXPCOL_END

  subroutine EXPCOL_TOTXSEC(LS, MS, ET, XSEC, IERROR)
    implicit none
    integer, intent(in) :: LS, MS
    real(8), intent(in) :: ET  !should be in eV
    real(8) :: XSEC
    real(8),pointer :: p(:)
    integer :: IERROR, iexpair
    iexpair = EXPCOLPair(LS, MS)
    if (iexpair .eq. 0) then
      ! no exponential type data was found
      IERROR = 1
      XSEC = 0.0d0
    else
      IERROR = 0
      p => EXPpar(iexpair)%totxsecpar
      XSEC = p(1)*dexp(1.0d0 - (ET/p(2))**p(3))
    end if
  end subroutine EXPCOL_TOTXSEC

  subroutine EXPCOL_RATE(LS, MS, T, rate)
    use calc,only : PI, BOLTZ, AVOG
    use gas,only : SPM
    implicit none
    integer, intent(in) :: LS, MS
    real(8), intent(in) :: T
    real(8), intent(out) :: rate
    ! calculate collision rates in SI unit: m^3/s
    real(8), pointer :: p(:)
    integer :: iexpair
    iexpair = EXPCOLPair(LS, MS)
    p => EXPpar(iexpair)%collrate
    rate = dsqrt(8*BOLTZ*T/SPM(1,LS,MS)) * p(1)*1d-20*(T/p(2))**p(3)
  end subroutine EXPCOL_RATE

  function EXPCOL_POT_IPAIR(IPAIR, R)
    implicit none
    ! calculate the potential energy
    ! R should be in Angstrom, return in eV
    integer, intent(in) :: IPAIR
    real(8) :: R, EXPCOL_POT_IPAIR
    EXPCOL_POT_IPAIR = EXPpar(IPAIR)%A * dexp(-EXPpar(IPAIR)%alpha * R)
  end function EXPCOL_POT_IPAIR

  function EXPCOL_POT_LSMS(LS, MS, R)
    implicit none
    integer :: LS, MS, ipair
    real(8) :: R, EXPCOL_POT_LSMS
    ipair = EXPCOLPair(LS, MS)
    if (ipair == 0) then
      write(*,*) "No exponential parameters for ",LS,MS
    else
      EXPCOL_POT_LSMS = EXPpar(IPAIR)%A * dexp(-EXPpar(IPAIR)%alpha * R)
    end if
  end function EXPCOL_POT_LSMS

  function EXPCOL_DENOM(ipair, r, b, Et)
    implicit none
    integer :: ipair
    real(8) :: b, Et, r, EXPCOL_DENOM
    EXPCOL_DENOM = 1.0d0 - b**2/r**2 - EXPCOL_POT(ipair, r)/Et
  end function EXPCOL_DENOM

  function EXPCOL_DENOMS(r)
    implicit none
    real(8) :: r, EXPCOL_DENOMS
    EXPCOL_DENOMS = 1.0d0 - brent_share(2)**2/r**2 - EXPCOL_POT(temp_int(1), r)/brent_share(1)
  end function EXPCOL_DENOMS

  function EXPCOL_SOLVERM(LS, MS, b, Et) result(RM)
    implicit none
    integer :: LS, MS
    real(8) :: b, Et, RM, lx, rx, tol=1.d-8, fa0, fb0
    real(8),external :: brent
    temp_int(1) = EXPCOLPair(LS, MS)
    brent_share(1) = Et
    brent_share(2) = b

    lx = 1.0d0
    fa0 = EXPCOL_DENOMS(lx)
    do while (fa0 > 0.0d0 .and. lx .ge. 1.0d-3)
      lx = lx / 1.2d0
      fa0 = EXPCOL_DENOMS(lx)
    end do
    if (lx < 1.0d-3) then
      write(*, '("Fail to solve for min ",I2,1X,I2," Et= ",G11.4," b= ",F7.4)') LS, MS, Et, b
      stop
    end if

    rx = 5.0d0
    fb0 = EXPCOL_DENOMS(rx)
    do while (fb0 < 0.0d0 .and. rx .le. 1.0d2)
      rx = rx * 1.2d0
      fb0 = EXPCOL_DENOMS(rx)
    end do
    if (rx > 1.0d2) then
      write(*, '("Fail to solve for max ",I2,1X,I2," Et= ",G11.4," b= ",F7.4)') LS, MS, Et, b
      stop
    end if

    RM = brent(lx, rx, EXPCOL_DENOMS, tol, fa0, fb0)
  end function EXPCOL_SOLVERM

  function EXPCOL_Chi(LS, MS, b, Et)
    ! calculate chi based on b and Et
    use calc, only : PI
    implicit none
    real(8) :: RM, R(NT), f(NT), EXPCOL_Chi, b, Et
    integer :: i, ipair,  LS, MS
    real(8) :: a

    ipair = EXPCOLPair(LS, MS)
    RM = EXPCOL_SOLVERM(LS, MS, b, Et)
    a = 0.0d0
    do i = 1,NT
      R(i) = RM/gx(i)
      f(i) = dsqrt(1.0d0-gx(i)**2)/dsqrt(EXPCOL_DENOM(ipair,R(i),b,Et))
      a = a + f(i)*gw(i)
    end do

    EXPCOL_Chi = PI-2.0d0*b/RM*a
  end function EXPCOL_Chi

  subroutine EXPCOL_Scatter(LS,MS,B,ET0,VR,VRC,VRCP,IDT)
    ! VR: adjusted speed
    ! VRC: adjusted velocity
    ! VRCP: scattered velocity
    USE CALC, only : EVOLT, PI
    USE GAS, only : SPM
    implicit none
    integer :: LS, MS, IDT
    real(8) :: VRC(3), VR, VRCP(3), B,RANF,ET0
    real(8) :: CHI, CCHI, SCHI, EPSI, CEPSI, SEPSI, D

    CHI = EXPCOL_Chi(LS,MS,B,ET0)
    CCHI = DCOS(CHI); SCHI = DSIN(CHI)
    CALL ZGF(RANF,IDT)
    EPSI = RANF*2.0D0*PI
    CEPSI = DCOS(EPSI)
    SEPSI = DSIN(EPSI)

    D=DSQRT(VRC(2)**2+VRC(3)**2)
    VRCP(1) = CCHI*VRC(1) + SCHI*SEPSI*D
    VRCP(2) = CCHI*VRC(2) + SCHI*(VR*VRC(3)*CEPSI-VRC(1)*VRC(2)*SEPSI)/D
    VRCP(3) = CCHI*VRC(3) - SCHI*(VR*VRC(2)*CEPSI+VRC(1)*VRC(3)*SEPSI)/D
  end subroutine EXPCOL_Scatter

  function EXPCOL_VT(LS, MS, EV, EC)
    use CALC, ONLY: EVOLT
    implicit none
    real(8) :: EV, EC, EXPCOL_VT, Etref, alpha
    integer,intent(in) :: LS, MS
    integer :: ipair
    ipair = EXPCOLPair(LS, MS)
    Etref = EXPpar(ipair)%totxsecpar(2)*EVOLT
    alpha = EXPpar(ipair)%totxsecpar(3)

    EXPCOL_VT = (1.0d0 - EV/EC)
    EXPCOL_VT = EXPCOL_VT * dexp(-((EC - EV)/Etref)**alpha + (EC/Etref)**alpha)
  end function EXPCOL_VT

  function EXPCOL_PMAXEQ(x)
    ! x = Et/Ec
    implicit none
    real(8) :: EXPCOL_PMAXEQ,x
    ! temp_real(1) : RDOF
    ! temp_real(2) : alpha
    ! temp_real(3) : Ec
    ! temp_real(4) : Et,ref in Jourle
    EXPCOL_PMAXEQ = 1.d0 + (1.0d0 - temp_real(1)/2)*x/(1.0d0-x) - &
      & temp_real(2)*(temp_real(3)*x/temp_real(4))**temp_real(2)
    ! Eq 19 in report
  end function EXPCOL_PMAXEQ

  function EXPCOL_RT(LS,MS,EC,RDOF,IDT)
    ! get a probability E_rot/Ec
    ! EC should be in SI
    ! RDOF dof of rotational energy
    use CALC, only : EVOLT
    implicit none
    integer,intent(in) :: LS,MS,RDOF
    real(8),intent(in) :: EC
    integer :: IDT, samp_t, ipair, i
    real(8) :: EXPCOL_RT,RANF,xs,PROB,xout,fa0,fb0,a,b
    real(8),parameter :: tol = 1.0d-4
    real(8),external :: brent
    ipair = EXPCOLPair(LS,MS)
    temp_real(1) = dble(RDOF)
    temp_real(2) = EXPpar(ipair)%totxsecpar(3)
    temp_real(3) = EC
    temp_real(4) = EXPpar(ipair)%totxsecpar(2)*EVOLT

    if (RDOF == 2) then
      samp_t = 1
    else
      fb0 = EXPCOL_PMAXEQ(0.99d0)
      if (fb0 > 0) then
        samp_t = 1
      else
        samp_t = 2
        fa0 = EXPCOL_PMAXEQ(0.01d0)
      end if
    end if

    if (samp_t == 1) then
      xs = 1.0d0
      a = xs*dexp(-(EC*xs/temp_real(4))**temp_real(2))
      b = 0.d0
    else
      xs = brent(0.01d0,0.99d0,EXPCOL_PMAXEQ,tol,fa0,fb0)
      b = dble(RDOF)*0.5d0-1.0d0
      a = (1.0d0-xs)**b*xs*dexp(-(EC*xs/temp_real(4))**temp_real(2))
    end if

    i = 1
    do while (i > 0 .and. i < 101)
      call ZGF(xout,IDT)
      PROB = (1.0d0 - xout)**b*xout*dexp(-(EC*xout/temp_real(4))**temp_real(2))/a
      call ZGF(RANF,IDT)
      if (PROB > RANF) then
        i = -1
      else
        i = i+1
      end if
    end do

    if (i == -1) then
      EXPCOL_RT = 1.0d0 - xout
    else
      write(*, *) "EXPCOL_RT fails for EC = ",EC, " RDOF=", RDOF
      stop
    end if
  end function EXPCOL_RT
END MODULE EXPCOL
