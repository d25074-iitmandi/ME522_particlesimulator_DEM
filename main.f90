
!==============================================================================
program main
 use particle_dem
 !use dem_force
 use neigh_dem_force
 use dem_o
 implicit none
  ! Setup Variables
    type(Particle), allocatable :: p(:)
    integer :: n, num_steps, step, num_contacts, i
    real :: t_total, dt, current_time
    real :: L, B, H, r_val, m_val, box_min(3), box_max(3), max_diameter
    real :: kn, gamma_1, ke, max_speed, current_speed

    ! 1. Initialize simulation parameters
    n = 1000                  ! Number of particles
    t_total = 2.0           ! Total simulation time (seconds)
    dt = 0.0005             ! Time step (needs to be small for DEM)
    
    L = 5.0; B = 5.0; H = 10.0 ! Box dimensions
    box_min(1) = 0
    box_min(2) = 0
    box_min(3) = 0
    
    box_max(1) = L
    box_max(2) = B
    box_max(3) = H
    
    r_val = 0.25               ! Particle radius
    m_val = 1.0                ! Particle mass
    max_diameter = r_val * 2
    
    kn = 1000.0            ! Normal stiffness (Spring)
    gamma_1 = 500.0            ! Damping coefficient (Dashpot)

    num_steps = int(t_total / dt)
    allocate(p(n))

    ! 2. Initialize particles
    call initialize_particles(p, n, L, B, H, r_val, m_val)

  !  print *, "Starting DEM Simulation..."
  !  print *, "Time(s)    Kinetic Energy   Contacts   Max Speed"
  !  print *, "------------------------------------------------"

    ! 3. Main Kinematic Time Loop
    do step = 1, num_steps
        current_time = real(step) * dt

        call zero_forces(p, n)
        call add_gravity(p, n)
        !call compute_particle_contacts(p, n, kn, gamma_1, num_contacts)
        call compute_particle_contacts_grid(p, n, kn, gamma_1, num_contacts, &
                                          box_min, box_max, max_diameter)
        !call compute_wall_contacts(p, n, L, B, H, kn, gamma_1)
        call integrate_particles(p, n, dt)

        ! 4. Diagnostics and Output (print every 100 steps)
        if (mod(step, 100) == 0) then
            ke = compute_kinetic_energy(p, n)
           
            ! Calculate max speed
            max_speed = 0.0
            do i = 1, n
                current_speed = norm2(p(i)%vel)
                if (current_speed > max_speed) max_speed = current_speed
            end do

            call write_output(current_time, ke, num_contacts, max_speed)
            
        end if
    end do

    print *, "Simulation Complete."
    deallocate(p)

end program main
