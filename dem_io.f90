module dem_o
 use particle_dem
 implicit none
 
contains
  ! The following subroutine displays the time, kinetic energy, no. of particle contacts and maximum speed
 subroutine write_output(time, ke, contacts, max_speed,n)
  integer, intent(in) :: n
  real, intent(in) :: time, ke, max_speed
  integer, intent(in) :: contacts
  character(len=64) :: filename
 ! 1. Generate a single filename based on the total number of particles (n)
  write(filename, '("system_data_", I0, ".txt")') n
  
  ! 2. Open the file in 'append' mode to add a new row every timestep
  open(unit=100, file=trim(filename), status='unknown', position='append')
  
  ! 3. Write Time, Kinetic Energy, Contacts, and Max Speed to the text file
  write(100, '(F10.5, 3X, E12.4, 3X, I5, 3X, F10.4)') &
        time, ke, contacts, max_speed
        
  ! 4. Close the file to safely write to the disk
  close(100)
 end subroutine write_output
 
 end module dem_o
