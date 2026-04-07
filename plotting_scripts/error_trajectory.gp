# 1. Output settings for a high-quality PDF
set terminal pdfcairo size 8,5 lw 2 font "Times New Roman,16"
set output 'error_verification.pdf'

# 2. Define professional line styles
set style line 1 lc rgb '#b30000' lt 1 lw 2 pt 7 ps 1.0


set title "Numerical Integration Error (Free Fall)"
set xlabel "Time (s)"
set ylabel "Absolute Error |Numerical - Analytical| (m)"
set grid

# Use logscale on the Y-axis to easily see tiny floating point errors
set logscale y
set format y "10^{%L}"

# Define the analytical gravity equation
g = 9.81
h0 = 8.3849  # CHANGE THIS to your particle's starting height!
analytical(x) = h0 - 0.5 * g * x**2

# Restrict x and y ranges to make the curve clear
#set xrange [0:1]
#set yrange [-0.005:0.009]

# Plot Analytical Line vs DEM Points
plot 'results_final/free_fall.txt' using 1:(abs($5-analytical($1))) with linespoints ls 1 title 'DEM Simulation
