# 1. Output settings for a high-quality PDF
set terminal pdfcairo size 8,5 lw 2 font "Times New Roman,16"
set output 'physics_verification2.pdf'

# 2. Define professional line styles
set style line 1 lc rgb '#2ca02c' lt 1 lw 2 pt 7 ps 0.8 # Bouncing (Green Line+Points)

# ==========================================
# PLOT 2: Bouncing Particle
# ==========================================
set title "Test 2: Bouncing on a Flat Floor"
set xlabel "Time (s)"
set ylabel "Height, Z (m)"
set grid
set key top right

# Plot the bouncing trajectory
plot 'results_final/verify_bounce.txt' using 1:5 with line ls 1 title 'DEM Trajectory'
