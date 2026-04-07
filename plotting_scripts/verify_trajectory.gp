# 1. Output settings for a high-quality PDF
set terminal pdfcairo size 8,5 lw 2 font "Times New Roman,16"
set output 'physics_verification.pdf'

# 2. Define professional line styles
set style line 1 lc rgb '#d9534f' lt 1 lw 3          # Theoretical (Thick Red Line)
set style line 2 lc rgb '#0060ad' pt 6 ps 1.5 lw 2   # DEM Data (Open Blue Circles)


# ==========================================
# PLOT 1: Free Fall Verification
# ==========================================
set title "Test 1: Free Fall Trajectory"
set xlabel "Time (s)"
set ylabel "Height, Z (m)"
set grid

# Define the analytical gravity equation
g = 9.81
h0 = 8.3849  # CHANGE THIS to your particle's starting height!
analytical(x) = h0 - 0.5 * g * x**2

# Restrict x and y ranges to make the curve clear
# Set xrange [0:1.5]
set yrange [0:11]

# Plot Analytical Line vs DEM Points
plot analytical(x) with lines ls 1 title 'Analytical (y = y_0 - 0.5gt^2)', \
     'results_final/free_fall.txt' using 1:5 with points ls 2 title 'DEM Simulation
