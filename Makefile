# Define the compiler and flags
FC = gfortran
FFLAGS = -O2 -Wall

# Define the target executable name
TARGET = dem_sim

# Define the object files
OBJS = particle_dem.o dem_io.o dem_force.o main.o

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
	$(FC) $(FFLAGS) -c $<

main.o: main.f90 particle_dem.o dem_io.o dem_force.o
	$(FC) $(FFLAGS) -c $<

# Clean up rule to remove generated files
clean:
	rm -f *.o *.mod $(TARGET) particles_*.vtu
