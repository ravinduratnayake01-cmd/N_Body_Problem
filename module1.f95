! Gravity module
module gravity_module
    implicit none
    contains

    ! Calculate gravitational force of two bodies
    subroutine grav_force(pos_i, pos_j, force)
        implicit none
        real(8), intent(in) :: pos_i(3), pos_j(3)
        real(8), intent(out) :: force(3)
        real(8) :: r_vec(3), r_2, r_3, eps

        ! Regulizing gravitational potential
        eps = 0.5D0

        ! Vector i to j
        r_vec = pos_j - pos_i

        ! Distance squared
        r_2 = sum(r_vec**2) + eps**2

        ! Cubed
        r_3 = r_2 * sqrt(r_2)

        ! Force vector
        force = r_vec / r_3
    end subroutine grav_force

    ! Total potential energy
    function total_potential_energy(pos, N) result(U)
        implicit none
        integer, intent(in) :: N
        real(8), intent(in) :: pos(N, 3)
        real(8) :: U, r_vec(3), r_2, eps
        integer :: i, j

        U = 0.0D0
        eps = 0.5D0

        do i = 1, N-1
            do j = i+1, N
                r_vec = pos(j,:) - pos(i,:)
                r_2 = sum(r_vec**2) + eps**2
                U = U - 1.0D0 / sqrt(r_2)
            end do
        end do
    end function total_potential_energy

    ! Total half-step kinetic energy
    function total_kinetic_energy(vel, N) result(K)
        implicit none
        integer, intent(in) :: N 
        real(8), intent(in) :: vel(N, 3)
        real(8) :: K 
        integer :: i

        K = 0.0D0
        do i = 1, N
            K = K + 0.5D0 * sum(vel(i,:)**2)
        end do 
    end function total_kinetic_energy

    ! Total angular momentum
    function total_angular_momentum(pos, vel, N) result(L)
        implicit none
        integer, intent(in) :: N
        real(8), intent(in) :: pos(N, 3), vel(N, 3)
        integer :: i
        real(8) ::L(3), r(3), v(3), l_i(3)

        L = 0.0D0
        do i = 1, N
            r = pos(i,:)
            v = vel(i,:)

            l_i(1) = r(2)*v(3) - r(3)*v(2)
            l_i(2) = r(3)*v(1) - r(1)*v(3)
            l_i(3) = r(1)*v(2) - r(2)*v(1)

            L = L +l_i
        end do
    end function total_angular_momentum

    ! Barycenter
    function barycentric_velocity(vel, N) result(Vbc)
        implicit none
        integer, intent(in) :: N
        real(8), intent(in) :: vel(N,3)
        real(8) :: Vbc(3)
        integer :: i

        Vbc = 0.0D0
        do i = 1, N
            Vbc = Vbc + vel(i,:)
        end do
        Vbc = Vbc / real(N, kind=8)
    end function barycentric_velocity


end module gravity_module

! Virial module
module virial_module
    use gravity_module
    implicit none
    contains

    function virial_ratio(pos, vel, N) result(Q)
        implicit none
        integer, intent(in) :: N
        real(8), intent(in) :: pos(N, 3), vel(N, 3)
        real(8) :: Q, K, U

        U = total_potential_energy(pos, N)
        K = total_kinetic_energy(vel, N)

        if (abs(U) > 1.0D-10) then
            Q = 2.0D0 * K/abs(U)
        else
            Q = -1.0D0
        end if
    end function virial_ratio


end module virial_module

! Leap-Frog Module
module nbody_module
    use gravity_module
    implicit none
    contains

    ! Total gravitational force on each body
    subroutine compute_all_forces(pos, force, N)
        implicit none
        integer, intent(in) :: N
        real(8), intent(in) :: pos(N,3)
        real(8), intent(out) :: force(N,3)
        integer :: i, j
        real(8) :: f_ij(3)

        ! Looping over all body pairs
        force = 0.0D0

        do i = 1, N-1
            do j = i+1, N
                if (i /= j) then
                    call grav_force(pos(i,:), pos(j,:), f_ij)
                    force(i,:) = force(i,:) + f_ij
                    force(j,:) = force(j,:) - f_ij
                end if
            end do
        end do
    end subroutine compute_all_forces

    
    ! Write ASCII file
    subroutine write_positions(pos, N)
        implicit none
        integer, intent(in) :: N
        real(8), intent(in) :: pos(N,3)
        integer :: i
        
        open(unit=10, file='positions.dat', status='replace', action='write')
        
        do i = 1, N
            write(10, '(F12.6,1X,F12.6,1X,F12.6)') pos(i,1), pos(i,2), pos(i,3)
        end do

        close(10)
    end subroutine write_positions

    ! Write output in snapshots/every few steps
    subroutine write_snapshot(pos, vel, N, step)
        implicit none
        integer, intent(in) :: N, step
        real(8), intent(in) :: pos(N,3), vel(N,3)
        integer :: i
        character(len=30) :: filename

        write(filename, '("snapshot_", I4.4, ".dat")') step
        open(unit=20, file=filename, status="replace", action="write")

        do i = 1, N
            write(20, '(F12.6,1X,F12.6,1X,F12.6,1X,F12.6,1X,F12.6,1X,F12.6)') &
                pos(i,1), pos(i,2), pos(i,3), vel(i,1), vel(i,2), vel(i,3)
        end do

        close(20)
    end subroutine write_snapshot

    ! ***Main*** Leap-frog integrator loop
    subroutine leapfrog_integrate(pos, vel, N, steps, output_interval, dt)
        implicit none
        integer, intent(in) :: N, steps, output_interval
        real(8), intent(inout) :: pos(N,3), vel(N,3)
        real(8), intent(in) :: dt
        real(8), allocatable :: force(:,:)
        integer :: j
        real(8) :: U, K, E
        real(8) :: L(3), Vbc(3)

        allocate(force(N,3))
        force = 0.0D0

        ! Initial force
        call compute_all_forces(pos, force, N)
        vel = vel + 0.5D0 * force * dt

        open(unit=30, file='energy.dat', status='replace', action='write')
        open(unit=40, file='angular_momentum.dat', status='replace', action='write')
        open(unit=50, file='barycenter_velocity.dat', status='replace', action='write')

        ! Time loop for leap frog
        do j = 1, steps
            ! Drift calculation, half step velocities
            pos = pos + vel*dt

            ! Update force
            call compute_all_forces(pos, force, N)

            ! Kick calculation, full step
            vel = vel + force*dt

            ! Total energy calculation
            U = total_potential_energy(pos, N)
            K = total_kinetic_energy(vel, N)
            E = U + K
            write(30, '(I6,1X,3ES14.6)') j, U, K, E

            ! Angular momentum
            L = total_angular_momentum(pos, vel, N)
            write(40, '(I6,1X,3ES14.6)') j, L(1), L(2), L(3)

            ! Barycentr velocity
            Vbc = barycentric_velocity(vel, N)
            write(50, '(I6,1X,3ES14.6)') j, Vbc(1), Vbc(2), Vbc(3)


            ! Output snapshots
            if (mod(j, output_interval) == 0) then
                call write_snapshot(pos, vel, N, j)
                print *, "Step", j, "complete"
            end if

        end do

        close(30)
        close(40)
        close(50)

        deallocate(force)
    end subroutine leapfrog_integrate


end module nbody_module