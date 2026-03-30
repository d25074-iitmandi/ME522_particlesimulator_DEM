module particle_dem
 implicit none
 
 type :: Particle
  real :: radius
  real :: pos(3)
  real :: vel(3)
  real :: mass
  real :: force(3)
 end type Particle
  
  real, parameter :: g = 9.81 ! acceleration due to gravity

end module particle_dem
