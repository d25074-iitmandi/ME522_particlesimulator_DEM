# Set output for a high-quality PDF
set terminal pdfcairo size 8,5 lw 2 font "Times New Roman,16"
set output 'serialvkinetic.pdf'

# Define contrasting styles
# Style 1 (Serial): Thick, light-red solid line
set style line 1 lc rgb '#d9534f' lt 1 lw 3

# Style 2 (Parallel): Dark, transparent circles (points)
# pt 6 is an open circle, pt 7 is a solid circle
#set style line 2 lc rgb '#292b2c' pt 6 ps 1.5 lw 2 
set style line 2 lc rgb '#d292b2c' lt 1 lw 3
 
#set title "Verification of OpenMP Implementation (Serial vs. Parallel)"
set xlabel "Time (s)"
set ylabel "Total Kinetic Energy (J)"
set grid

# Use logscale to prove they match even at the smallest energy scales
set logscale y 
set format y "10^{%L}"

set key right top 

# Plot Serial as lines, and Parallel as points overlaid on top
plot 'results_final/system_data_5000_serial.txt' using 1:2 with lines ls 1 title 'Serial (1 Thread)', \
     'results_final/system_data_5000_parallel.txt' using 1:2 with lines ls 2 title 'Parallel (8 Threads)'
