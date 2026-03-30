module dem_o
 use particle_dem
 implicit none
 
contains
  ! The following subroutine displays the time, kinetic energy, no. of particle contacts and maximum speed
 subroutine write_output(time, ke, contacts, max_speed)
  real, intent(in) :: time, ke, max_speed
  integer, intent(in) :: contacts
        
  print '(F8.4, 3X, E12.4, 3X, I5, 3X, F10.4)', &
              time, ke, contacts, max_speed
 end subroutine write_output
 
 end module dem_o
