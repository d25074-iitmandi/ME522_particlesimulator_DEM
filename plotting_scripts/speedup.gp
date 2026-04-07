# Set output format and file name
set terminal pdfcairo size 8,8 lw 2 font "Times New Roman,20"
set output 'speedup.pdf'

# Define line styles
set style line 1 lc rgb '#0060ad' lt 1 lw 2 pt 7 ps 1.5 # Actual Data
set style line 2 lc rgb '#dd181f' lt 2 lw 2            # Ideal/Reference Line

# --- PLOT SPEEDUP ---
#set title "Speedup" font "Times New Roman, 30"
set xlabel "Threads (p)"
set ylabel "Speedup S(p) = T_1/T_p"
set grid
set key left top
set xrange [1:8]
set yrange [1:8]
plot x with lines ls 2 title 'Ideal', 'performance_analysis/scaling.dat' using 1:3 with linespoints ls 1 title 'Observed'

