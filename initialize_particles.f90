! The following subroutine initialize the particles by assigning them mass, radius and associating their position, velocity and force
! in accordance to the dimensions of the box
subroutine initialize_particles(p, n, L, B, H, r_val, m_val)
        type(Particle), intent(inout) :: p(:)
        integer, intent(in) :: n
        real, intent(in) :: L, B, H, r_val, m_val
        integer :: i

        call random_seed()
        do i = 1, n
            ! Randomize positions safely inside the box to avoid initial wall overlap
            ! The boundary begins at diameter away from the actual distance
            call random_number(p(i)%pos)
            p(i)%pos(1) = r_val + p(i)%pos(1) * (L - 2.0*r_val) 
            p(i)%pos(2) = r_val + p(i)%pos(2) * (B - 2.0*r_val)
            p(i)%pos(3) = r_val + p(i)%pos(3) * (H - 2.0*r_val)
            
            p(i)%vel = 0.0 !Initial velocity set to zero
            p(i)%force = 0.0 ! Initial force set to zero
            p(i)%radius = r_val ! Radius of the spherical particles
            p(i)%mass = m_val ! Mass of the spherical particles
        end do
end subroutine initialize_particles
