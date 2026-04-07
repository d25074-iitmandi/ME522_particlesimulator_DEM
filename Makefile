# Define the compiler and flags
FC = gfortran
FFLAGS = -O3 -Wall -fopenmp -ffree-line-length-none -pg

# Define the target executable name
TARGET = dem_sim

# Define the object files
OBJS = particle_dem.o dem_io.o dem_force.o main.o
#OBJS = particle_dem.o dem_io.o neigh_dem_force.o main.o

# The default rule: build the executable
all: $(TARGET)

# Link the object files to create the executable
$(TARGET): $(OBJS)
	$(FC) $(FFLAGS) -o $@ $^

# --- Dependency Rules ---
# These tell Make which files must be compiled first

particle_dem.o: particle_dem.f90
	$(FC) $(FFLAGS) -c $<

dem_io.o: dem_io.f90 particle_dem.o
	$(FC) $(FFLAGS) -c $<
dem_force.o: dem_force.f90 particle_dem.o
#neigh_dem_force.o: neigh_dem_force.f90 particle_dem.o
	$(FC) $(FFLAGS) -c $<

main.o: main.f90 particle_dem.o dem_io.o dem_force.o
#main.o: main.f90 particle_dem.o dem_io.o neigh_dem_force.o
	$(FC) $(FFLAGS) -c $<

# Clean up rule to remove generated files
clean:
	rm -f *.o *.mod $(TARGET)
	rm *.txt
required_plot:
	gnuplot plotting_scripts/verify_trajectory.gp
	gnuplot plotting_scripts/error_trajectory.gp
	gnuplot plotting_scripts/bounce.gp
	gnuplot plotting_scripts/kineticenergy1.gp
	gnuplot plotting_scripts/particle_config.gp
	
parallel_plot:
	gnuplot plotting_scripts/serialvkinetic.gp
	
performance_analysis_plot:
	gnuplot plotting_scripts/speedup.gp
	gnuplot plotting_scripts/efficiency.gp
	
	
