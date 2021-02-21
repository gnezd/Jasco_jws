=begin
raw_fin = (File.open '2462.jws', 'rb')
raw = raw_fin.read.freeze
raw_fin.close

start = "4c40".to_i(16)
ending = "d1a7".to_i(16)
puts "parsing #{ending + 1 - start} bytes"

(0..(ending+1-start)/4).each do |i|
    puts raw[start+4*i..start+4*i+3].unpack("f")
end
  if measparam.size > 98
    format_str_measparam = 'H' * 56 + "f" + "H" * 256 + "f" + 'H' * 480 + 'f' + "H*"
  else
    format_str_measparam = 'x' * 38 + "f" + "x*"
  end

require 'ole/storage'

filelist = Dir.glob './testdata/*.jws'

filelist.each do |file|
  basename = File.basename file, '.jws'
  puts basename
  handle = Ole::Storage.open(file, 'rb')
  ydata = handle.file.read 'Y-Data'
  measparam = handle.file.read('MeasParam')
  datainfo = handle.file.read('DataInfo')
  num_pt, wn_start, wn_end, res = (datainfo.unpack 'H40LdddH*')[1..4]
  puts "Num of pt: #{num_pt}, ydata size: #{ydata.size}, ratio = #{ydata.size.to_f / num_pt}"
  puts "Begin and end: #{wn_start} - #{wn_end}"
  puts "Resolution: #{res}. (wvend - wvstart)/res = #{(wn_end - wn_start) / res}"
  puts "The first 8 data:"
  puts ydata[0..].unpack('f*').join '|'
  puts "And last eight:"
  puts ydata[-8..-1].unpack('f*').join '|'
  puts ""
end
#puts @measparam[39*4 .. 39*4+3].unpack('f')[0]
#puts @measparam[100*4 .. 100*4+3].unpack('f')[0]
#puts "Spectrum points: #{@ydata.size}"

=end
require './lib.rb'
j1 = JWSFile.new './testdata/2462.jws'

jasco_export_fin = File.open 'testdata/2462.txt', 'r'
txt_lines = jasco_export_fin.readlines
jasco_export_fin.close

txt_data = Array.new() {[0.0, 0.0]}
while !(txt_lines.shift.match(/^XYDATA/))
end
while match = txt_lines.shift.match(/^(\d+.?\d+)\t(\d+.?\d+)/)
  txt_data.push [match[1].to_f, match[2].to_f]
end

puts j1.size
raise "size mismatch with exported data" if txt_data.size != j1.data.size

# Compare with exported txt
j1.data.each_with_index do |pt, i|
  if (pt[0] - txt_data[i][0]) > 0.001 || (pt[1] - txt_data[i][1]) > 0.001
    puts "#{i}: exported#{txt_data[i].join(' - ')}, #{pt.join(' - ')}"
  end
end
