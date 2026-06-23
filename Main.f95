program N_Body_Problem
    use gravity_module
    use nbody_module
    use virial_module
    implicit none

    ! Declare variables
    integer :: N, i, seed_size, j
    integer, allocatable :: seed(:)
    real(8), allocatable :: pos(:,:), vel(:,:)
    real(8) :: R = 1.0D0, x, y, z, distance, Omega = 1.0D0
    real(8) :: vbx, vby, vbz
    integer, parameter :: steps = 5000, output_interval = 100
    real(8), parameter :: dt = 0.001D0
    real(8) :: U, K
    integer :: start_clock, end_clock, rate
    real(8) :: complexity_time
    real(8) :: Q


    print *, "Input Number of Bodies/Objects (N):"
    read *, N

    ! Making the Arrays
    allocate(pos(N,3))
    allocate(vel(N,3))
    pos = 0.0D0
    vel = 0.0D0

    ! Set Seed
    call random_seed(size=seed_size)
    allocate(seed(seed_size))
    call random_seed(get=seed)
    write (*, *) "Seed", seed

    ! Set position and velocity
    i = 1
    do while (i <= N)
        call random_number(x)
        call random_number(y)
        call random_number(z)

        ! To get -1 to 1 range
        x = 2.*x - 1.
        y = 2.*y - 1.
        z = 2.*z - 1.

        distance = sqrt(x**2 + y**2 + z**2)

        ! Set position and velocity inside sphere
        if (distance <= 1.0) then
            pos(i, 1) = R*x
            pos(i, 2) = R*y
            pos(i, 3) = R*z

            vel(i, 1) = -Omega * pos(i, 2)
            vel(i, 2) = Omega * pos(i, 1)
            vel(i, 3) = 0.0D0

            Q = virial_ratio(pos, vel, N)

            i = i+1
        end if
    end do

    ! Barycentric corrections
    vbx = 0.0D0
    vby = 0.0D0
    vbz = 0.0D0
    
    do j = 1, N
        vbx = vbx + vel(j, 1)
        vby = vby + vel(j, 2)
        vbz = vbz + vel(j, 3)
    end do

    do j = 1, N
        vel(j, 1) = vel(j, 1) - vbx/N
        vel(j, 2) = vel(j, 2) - vby/N
        vel(j, 3) = vel(j, 2) - vbz/N
    end do


    ! Virial ratio
    Q = virial_ratio(pos, vel, N)
    print *, "Initital virial value:", Q

    ! Call Subroutine to write positions
    call write_positions(pos, N)
    print *, "Initial positions writing complete"

    ! Compute total potential energy
    U = total_potential_energy(pos, N)
    print *, "Total potential energy:", U

    ! Compute total kinetic energy
    K = total_kinetic_energy(vel, N)
    print *, "Total kinetic energy:", K

    print *, "Total Energy:", U+K

    ! Call leap-frog integration
    call leapfrog_integrate(pos, vel, N, steps, output_interval, dt)
    print *, "Integration complete"

    ! Complexity
    call system_clock(count_rate=rate)
    call system_clock(start_clock)
    call leapfrog_integrate(pos, vel, N, steps, output_interval, dt)
    call system_clock(end_clock)

    complexity_time = real(end_clock-start_clock, kind=8) / real(rate, kind=8)
    print *, "Time taken :", complexity_time

    ! Temp, Verification

    ! Deallocation
    deallocate(pos, vel, seed)

end program N_Body_Problem


