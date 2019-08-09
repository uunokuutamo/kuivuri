set terminal png
set output "test1440.png"
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M\n%m/%d"
set grid
plot "lammot10.tsv" using 1:2 with lines title "Ulko", "lammot10.tsv" using 1:3 with lines title "Meno", "lammot10.tsv" using 1:4 with lines title "Paluu",
