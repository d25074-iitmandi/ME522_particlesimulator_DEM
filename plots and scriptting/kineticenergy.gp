# 1. Improved terminal settings
set terminal pdfcairo size 8,6 lw 2 font "Times New Roman,18"
set output 'kinetic_energy_comparison.pdf'

# 2. Professional Color Palette (Cool-to-Warm or Gradient)
set style line 1 lc rgb '#99ccff' lt 1 lw 2.5  # N=200 (Light Blue)
set style line 2 lc rgb '#0066cc' lt 1 lw 2.5  # N=1000 (Medium Blue)
set style line 3 lc rgb '#003366' lt 1 lw 2.5  # N=5000 (Dark Blue)

#set title "Normalized System Kinetic Energy"
set xlabel "Time (s)"
set ylabel "KE per Particle (J/particle)"
set grid xtics ytics ls 0 lc rgb 'gray' lw 1

# 3. Handle the Y-axis range
# Using logscale is often better for energy decay
set logscale y 
set format y "10^{%L}"

set key right top 

# 4. Normalize using 'using 1:($2/N)' to compare apples to apples
plot 'system_data_200.txt'  using 1:($2/200)  with lines ls 1 title 'N=200', \
     'system_data_1000.txt' using 1:($2/1000) with lines ls 2 title 'N=1000', \
     'system_data_5000.txt' using 1:($2/5000) with lines ls 3 title 'N=5000'
