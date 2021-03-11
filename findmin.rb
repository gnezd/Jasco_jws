require 'csv'
require './lib.rb'

csv_in = ARGV[0]
raise "Input file name in argument" unless csv_in
raise "File #{csv_in} is not found" unless File.exist? csv_in
spect_name = File.basename csv_in, '.csv'
puts csv_in
#csv_in = 'output/21c01-3-6.csv'
csvin = File.open csv_in, 'r'
csv = CSV.new(csvin)
data = csv.read.map{|pt| [pt[0].to_f, pt[1].to_f]}
csvin.close

Dir.mkdir('plot') if !Dir.exist? 'plot'

# PEAK PICKING PARAMETERS
c = 10 # Moving average +- neighborhood
threshold = 94.4 # Pick only peaks lower than this
radius = 10 # Distance sparser than such

ma = Array.new
(0+c..data.size-c-1).each do |i|
    ma.push [data[i][0], ((data[i-c..i+c].map {|t| t[1].to_f}).sum.to_f)/(2*c+1)]
end
out = File.open "plot/#{spect_name}_ma.csv", 'w'
csvout = CSV.new(out)
ma.each do |entry|
    csvout << entry
end
out.close

local_min = Array.new
(1..ma.size-2).each do |i|
    if ma[i][1] < ma[i+1][1] && ma[i][1] < ma[i-1][1]
        # Local minima
        local_min.push ma[i] if ma[i][1] < threshold
    end
end

loosened = Array.new
i = 0
while i < local_min.size-1
    if (local_min[i][0] - local_min[i+1][0])**2 + (local_min[i][1] - local_min[i+1][1])**2 > radius**2
        loosened.push local_min[i]
        loosened.push local_min[i+1] if i == local_min.size-2
        i +=1
    else
        loser = (local_min[i][1] - local_min[i+1][1] > 0) ? i : i+1
        #puts "comparing #{local_min[i..i+1]}, loser is #{loser}"
        local_min.delete_at loser
        #puts "deleting at #{loser}"
    end
end
puts (loosened.map {|pt| pt[0].to_i}).reverse.join ', '
out = File.open "plot/#{spect_name}_min.csv", 'w'
csvout = CSV.new out
loosened.each do |entry|
    csvout << entry
end
out.close

out = File.open "plot/#{spect_name}.gplot", 'w'
gnuplot_content = <<~END
set datafile separator ','
set style line 1 lc rgb '#000' lw 3
set style line 2 lc rgb '#f00'
set terminal svg mouse enhanced standalone size 1600 800
set output 'plot/#{spect_name}.svg'
set xrange [4500:500]
plot 'plot/#{spect_name}_ma.csv' with lines t 'ma' ls 1, \
'#{csv_in}' with lines t 'raw', \
'plot/#{spect_name}_min.csv' using 1:2:(sprintf("<%d, %d>", $1, $2)) with labels point pt 7 tc ls 2 offset char 1,1 t 'picks'
END
out.puts gnuplot_content
out.close
result = `#{which 'gnuplot'} plot/#{spect_name}.gplot`
