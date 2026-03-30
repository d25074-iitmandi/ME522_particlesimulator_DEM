module particle_dem
 implicit none
 
 type :: Particle
  real :: radius
  real :: pos(3)
  real :: vel(3)
  real :: mass
 end type Particle
 
 end module particle_dem
