module dem_force
 use particle_dem
 implicit none
 
contains
! The following subroutine ensures the force on particle at the beginning is zero  
subroutine zero_forces(p, n)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        integer :: i
        do i = 1, n
            p(i)%force = 0.0
        end do
end subroutine zero_forces
    
! The following subroutine models contact force between the particles using the spring-dashpot model 
subroutine compute_particle_contacts(p, n, kn, gamma_1, num_contacts)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        real, intent(in) :: kn, gamma_1
        integer, intent(out) :: num_contacts
        
        integer :: i, j
        real :: rij(3), dij, delij, nij(3), rel_v(3), vij, fc_mag
        real :: fc_vec(3)

        num_contacts = 0

        ! Loop over all unique pairs (i, j)
        do i = 1, n - 1
            do j = i + 1, n
                rij = p(j)%pos - p(i)%pos
                dij = norm2(rij)
                delij = (p(i)%radius + p(j)%radius) - dij
                
                if (delij > 0.0 .and. dij > 0.0) then
                    num_contacts = num_contacts + 1
                    nij = rij / dij
                    
                    ! Relative velocity: (vj - vi)
                    rel_v = p(j)%vel - p(i)%vel
                    ! Normal component of relative velocity
                    vij = dot_product(rel_v, nij)
                    
                    ! Contact force magnitude (Spring + Dashpot)
                    fc_mag = (kn * delij) - (gamma_1 * vij)
                    
                    ! APPLYING THE FIX: Prevent non-physical attractive force
                    fc_mag = max(0.0, (kn * delij) - (gamma_1 * vij))
                    
                    ! Force vector
                    fc_vec = fc_mag * nij
                    
                    ! Equal and opposite forces
                    p(j)%force = p(j)%force + fc_vec
                    p(i)%force = p(i)%force - fc_vec
                end if
            end do
        end do
end subroutine compute_particle_contacts

! The following subroutine models the force from contact with the wall
subroutine compute_wall_contacts(p, n, L, B, H, kn, gamma_1)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        real, intent(in) :: L, B, H, kn, gamma_1
        integer :: i
        real :: del, rel_v, fc

        do i = 1, n
            ! X-axis walls (x=0 and x=L)
            del = p(i)%radius - p(i)%pos(1)
            if (del > 0.0) then
                rel_v = -p(i)%vel(1) ! Wall is stationary
                !fc = (kn * del) - (gamma_1 * rel_v)
                fc = max(0.0, (kn * del) + (gamma_1 * rel_v))
                p(i)%force(1) = p(i)%force(1) + fc
            end if
            
            del = p(i)%pos(1) + p(i)%radius - L
            if (del > 0.0) then
                rel_v = p(i)%vel(1)
                fc = max(0.0, (kn * del) + (gamma_1 * rel_v))
                p(i)%force(1) = p(i)%force(1) - fc
            end if

            ! Y-axis walls (y=0 and y=B)
            del = p(i)%radius - p(i)%pos(2)
            if (del > 0.0) then
                rel_v = -p(i)%vel(2)
                fc = max(0.0, (kn * del) + (gamma_1 * rel_v))
                p(i)%force(2) = p(i)%force(2) + fc
            end if
            
            del = p(i)%pos(2) + p(i)%radius - B
            if (del > 0.0) then
                rel_v = p(i)%vel(2)
                fc = max(0.0, (kn * del) + (gamma_1 * rel_v))
                p(i)%force(2) = p(i)%force(2) - fc
            end if

            ! Z-axis walls (z=0 and z=H)
            del = p(i)%radius - p(i)%pos(3)
            if (del > 0.0) then
                rel_v = -p(i)%vel(3)
                fc = max(0.0, (kn * del) + (gamma_1 * rel_v))
                p(i)%force(3) = p(i)%force(3) + fc
            end if
            
            del = p(i)%pos(3) + p(i)%radius - H
            if (del > 0.0) then
                rel_v = p(i)%vel(3)
                fc = max(0.0, (kn * del) + (gamma_1 * rel_v))
                p(i)%force(3) = p(i)%force(3) - fc
            end if
        end do
end subroutine compute_wall_contacts

! The following subroutine updates the particle's velocity and position after every time step
subroutine integrate_particles(p, n, dt)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        real, intent(in) :: dt
        integer :: i

        do i = 1, n
            ! v(t) = v(t-1) + (F/m)*dt
            p(i)%vel = p(i)%vel + (p(i)%force / p(i)%mass) * dt
            ! x(t) = x(t-1) + v(t)*dt
            p(i)%pos = p(i)%pos + p(i)%vel * dt
        end do
end subroutine integrate_particles

end module dem_force
