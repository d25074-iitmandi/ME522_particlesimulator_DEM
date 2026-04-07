# 1. Output setup for a sharp PDF
set terminal pdfcairo size 8,8 lw 2 font "Times New Roman,16"
set output 'particle_configuration_3d.pdf'

# 2. Configure the 3D visualization view
set title "3D System Configuration (N=200)" font ",20"
set xlabel "X (m)"
set ylabel "Y (m)"
set zlabel "Z (m)"
set border 4095 lw 1.5 lc rgb '#333333'

set grid
set xyplane at 0  # Put the xy-grid exactly at z=0

# Define your box dimensions (MUST match your Fortran initialization!)
set xrange [0:5.0]
set yrange [0:5.0]
set zrange [0:10.0]

# Adjust the viewing angle (rot_x, rot_z) to find the best perspective
set view 60, 60, 1, 1

# 3. Define the particle style ("Pseudospheres")
# We use solid circles (pt 7) and enable depth ordering (hidden3d style)
# to make particles in the back covered by particles in the front.
set style line 1 lc rgb '#0060ad' pt 7 ps 0.45 

# Set depth ordering for 'with points' plots
set hidden3d
set surface

# 4. Generate the plot
# 'splot' is used for 3D plotting
splot 'results_final/particle_config200_xyz.txt' using 5:6:7 with points ls 1 title 'Particles'
