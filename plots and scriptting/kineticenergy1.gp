# Set output format and file name
set terminal pdfcairo size 8,8 lw 2 font "Times New Roman,20"
set output 'kinetic energy.pdf'

# Define line styles
set style line 1 lc rgb '#99ccff' lt 1 lw 2.5  # N=200 (Light Blue)
set style line 2 lc rgb '#0066cc' lt 1 lw 2.5  # N=1000 (Medium Blue)
set style line 3 lc rgb '#003366' lt 1 lw 2.5  # N=5000 (Dark Blue)

set xlabel "Time (s)"
set ylabel "Kinetic Energy"
set grid xtics ytics ls 0 lc rgb 'gray' lw 1
#set logscale y

set key right top
set xrange [0:2]
#set yrange [0:1.1] # Show 0% to 110% to see the 1.0 line clearly
# Draw a horizontal line at 1.0 (100% efficiency)
plot 'system_data_200.txt' using 1:2 with lines ls 1 title 'N=200', 'system_data_1000.txt' using 1:2 with lines ls 2 title 'N=1000', 'system_data_5000.txt' using 1:2 with lines ls 3 title 'N=5000'


