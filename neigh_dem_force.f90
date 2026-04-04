module neigh_dem_force
 use particle_dem
 use omp_lib
 implicit none
 
contains


subroutine initialize_particles(p, n, L, B, H, r_val, m_val)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        real, intent(in) :: L, B, H, r_val, m_val
        integer :: i
        integer :: n1
  integer, allocatable :: seed(:)

  ! 1. Determine the required seed size for your compiler
  call random_seed(size=n1)
  allocate(seed(n1))

  ! 2. Fill the array with a fixed set of integers for repeatability
  seed = 12345 
  
  ! 3. Set the seed
  call random_seed(put=seed)

        !call random_seed()
        do i = 1, n
            call random_number(p(i)%pos)
            p(i)%pos(1) = r_val + p(i)%pos(1) * (L - 2.0*r_val)
            p(i)%pos(2) = r_val + p(i)%pos(2) * (B - 2.0*r_val)
            p(i)%pos(3) = r_val + p(i)%pos(3) * (H - 2.0*r_val)
            
            p(i)%vel = 0.0
            p(i)%force = 0.0
            p(i)%radius = r_val
            p(i)%mass = m_val
        end do
end subroutine initialize_particles

! The following subroutine ensures the force on particle at the beginning is zero  
subroutine zero_forces(p, n)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        integer :: i
        do i = 1, n
            p(i)%force = 0.0
        end do
end subroutine zero_forces

 subroutine add_gravity(p, n)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        integer :: i
        do i = 1, n
            p(i)%force(3) = p(i)%force(3) - (p(i)%mass * g)
        end do
    end subroutine add_gravity

    
! The following subroutine models contact force between the particles using the spring-dashpot model 
subroutine compute_particle_contacts_grid(p, n, kn, gamma_1, num_contacts, &
                                          box_min, box_max, max_diameter)

        
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        real, intent(in) :: kn, gamma_1, max_diameter
        real, intent(in) :: box_min(3), box_max(3)
        integer, intent(out) :: num_contacts
        
        ! Grid variables
        real :: cell_size
        integer :: ncx, ncy, ncz, total_cells
        integer, allocatable :: head(:), lscl(:)
        integer :: cx, cy, cz, c, nx, ny, nz, nc
        integer :: dx, dy, dz
        
        ! Physics variables
        integer :: i, j
        real :: rij(3), dij, delij, nij(3), rel_v(3), vij, fc_mag
        real :: fc_vec(3)

        num_contacts = 0
        
        ! --- 1. SETUP THE GRID ---
        ! Cell size must be slightly larger than max diameter
        cell_size = max_diameter * 1.01 
        
        ncx = floor((box_max(1) - box_min(1)) / cell_size) + 1
        ncy = floor((box_max(2) - box_min(2)) / cell_size) + 1
        ncz = floor((box_max(3) - box_min(3)) / cell_size) + 1
        total_cells = ncx * ncy * ncz
        
        allocate(head(total_cells))
        allocate(lscl(n))
        
        head = 0
        lscl = 0
        
        ! --- 2. BIN PARTICLES INTO CELLS (O(N) operation) ---
        ! This is done serially as it is extremely fast and avoids race conditions
        do i = 1, n
            cx = floor((p(i)%pos(1) - box_min(1)) / cell_size) + 1
            cy = floor((p(i)%pos(2) - box_min(2)) / cell_size) + 1
            cz = floor((p(i)%pos(3) - box_min(3)) / cell_size) + 1
            
            ! Keep particles inside grid bounds safely
            cx = max(1, min(cx, ncx))
            cy = max(1, min(cy, ncy))
            cz = max(1, min(cz, ncz))
            
            ! Flatten 3D grid index to 1D array index
            c = cx + (cy - 1)*ncx + (cz - 1)*ncx*ncy
            
            ! Add particle to the linked list for this cell
            lscl(i) = head(c)
            head(c) = i
        end do

        ! --- 3. COMPUTE FORCES (Broad Phase + Narrow Phase) ---
        ! We parallelize over the particles, but use the grid to find neighbors
 !$omp parallel do default(none) shared(p, n, kn, gamma_1, head, lscl, ncx, ncy, ncz, cell_size, box_min) &
 !$omp private(i, j, cx, cy, cz, c, nx, ny, nz, nc, dx, dy, dz, rij, dij, delij, nij, rel_v, vij, fc_mag, fc_vec) &
 !$omp reduction(+:num_contacts) schedule(dynamic)
        do i = 1, n
            ! Find which cell particle 'i' is in
            cx = floor((p(i)%pos(1) - box_min(1)) / cell_size) + 1
            cy = floor((p(i)%pos(2) - box_min(2)) / cell_size) + 1
            cz = floor((p(i)%pos(3) - box_min(3)) / cell_size) + 1
            
            cx = max(1, min(cx, ncx))
            cy = max(1, min(cy, ncy))
            cz = max(1, min(cz, ncz))

            ! Search current cell and 26 adjacent cells
            do dx = -1, 1
                do dy = -1, 1
                    do dz = -1, 1
                        nx = cx + dx
                        ny = cy + dy
                        nz = cz + dz
                        
                        ! Check if neighbor cell is within simulation bounds
                        if (nx >= 1 .and. nx <= ncx .and. &
                            ny >= 1 .and. ny <= ncy .and. &
                            nz >= 1 .and. nz <= ncz) then
                            
                            nc = nx + (ny - 1)*ncx + (nz - 1)*ncx*ncy
                            j = head(nc)
                            
                            ! Loop through all particles 'j' in this neighbor cell
                            do while (j > 0)
                                ! Newton's 3rd Law check: Only compute if i < j to avoid double-counting
                                if (i < j) then
                                    rij = p(j)%pos - p(i)%pos
                                    dij = norm2(rij)
                                    delij = (p(i)%radius + p(j)%radius) - dij
                                    
                                    ! NARROW PHASE (Actual contact math)
                                    if (delij > 0.0 .and. dij > 0.0) then
                                        num_contacts = num_contacts + 1
                                        nij = rij / dij
                                        rel_v = p(j)%vel - p(i)%vel
                                        vij = dot_product(rel_v, nij)
                                        
                                        fc_mag = max(0.0, (kn * delij) - (gamma_1 * vij))
                                        fc_vec = fc_mag * nij
                                        
                                        !$omp atomic
                                        p(j)%force(1) = p(j)%force(1) + fc_vec(1)
                                        !$omp atomic
                                        p(j)%force(2) = p(j)%force(2) + fc_vec(2)
                                        !$omp atomic
                                        p(j)%force(3) = p(j)%force(3) + fc_vec(3)
                                        
                                        !$omp atomic
                                        p(i)%force(1) = p(i)%force(1) - fc_vec(1)
                                        !$omp atomic
                                        p(i)%force(2) = p(i)%force(2) - fc_vec(2)
                                        !$omp atomic
                                        p(i)%force(3) = p(i)%force(3) - fc_vec(3)
                                    end if
                                end if
                                
                                ! Move to the next particle in the neighbor cell
                                j = lscl(j)
                            end do
                        end if
                    end do
                end do
            end do
        end do
 !$omp end parallel do

        deallocate(head)
        deallocate(lscl)
end subroutine compute_particle_contacts_grid

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

function compute_kinetic_energy(p, n) result(ke)
        type(Particle), intent(in) :: p(:)
        integer, intent(in) :: n
        real :: ke
        integer :: i
        real :: speed_sq

        ke = 0.0
        do i = 1, n
            speed_sq = dot_product(p(i)%vel, p(i)%vel)
            ke = ke + 0.5 * p(i)%mass * speed_sq
        end do
end function compute_kinetic_energy

end module neigh_dem_force
