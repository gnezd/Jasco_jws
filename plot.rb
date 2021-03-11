require './lib.rb'


path = ARGV[0]
jwslist = Dir.glob path + '/*.jws'
#csvlist = Array.new
plotline = 'plot '
Dir.mkdir 'output' if !Dir.exist? 'output'
jwslist.each do |jws_path|
  begin
    jws = JWSFile.new jws_path
  rescue
    puts "Failed to open file #{jws_path}"
    next
  end
  smplname = File.basename jws_path, '.jws'
  csv_out = File.open('output/' + smplname + '.csv', 'w')
  jws.data.each do |pt|
    csv_out.puts pt.join ', '
  end
  csv_out.close
  plotline += "'output/#{smplname}.csv' using ($1):($2) with lines t '#{smplname}'" + ", \\" + "\n"
end

gplot_head = <<~HEADDER_END
set style line 1 lc rgb '#f89441' pt 20 #yo: KAT
set style line 2 lc rgb '#0c0887' pt 20 #bu: HA
set style line 3 lc rgb '#cb4679' pt 20 #rd: nitrone
set datafile separator ','
#set terminal png font helvetica 20 size 1600,800
#set terminal svg enhanced mouse standalone font 'helvetica,20' size 1600,800 lw 3
set terminal canvas font 'helvetica,20' size 1600,800 lw 3 jsdir './gnuplotjs/' mousing
set output 'ir.html'
set xlabel 'Wavenumber (cm-1)'
set xrange [4500:500]
set xtics nomirror scale 0.5, 0.25
set ytics nomirror
set key outside
set mxtics 10
set border 3
set ylabel 'T%'
HEADDER_END

gplot_out = File.open 'output/ir.gplot', 'w'
gplot_out.puts gplot_head
gplot_out.puts plotline
gplot_out.close
`#{which('gnuplot')} output/ir.gplot`