# Set output format and file name
set terminal pdfcairo size 8,8 lw 2 font "Times New Roman,20"
set output 'efficiency.pdf'

# Define line styles
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5 # Actual Data
set style line 2 lc rgb '#dd181f' lt 2 lw 2            # Ideal/Reference Line

# --- PLOT SPEEDUP ---
#set title "Efficiency"
set xlabel "Threads (p)"
set ylabel "Efficiency E(p) = S(p)/p"
set grid
set key right bottom
set xrange [1:8]
set yrange [0:1.1] # Show 0% to 110% to see the 1.0 line clearly
# Draw a horizontal line at 1.0 (100% efficiency)
plot 1.0 with lines ls 2 title '100% Efficient', \
     'performance_analysis/scaling.dat' using 1:4 with linespoints ls 1 title 'Observed'

