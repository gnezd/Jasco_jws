# Jasco IR JWS file reader
require 'ole/storage'
class JWSFile

  attr_reader :size, :wn_start, :wn_end, :name, :path, :data, :resolution
  def initialize jws_path
    ole_handle = Ole::Storage.open jws_path
    @name = File.basename(jws_path)
    @path = jws_path
    datainfo = ole_handle.file.read 'DataInfo'
    ydata = ole_handle.file.read('Y-Data').unpack 'f*'
    ole_handle.close
    @size, @wn_start, @wn_end, @resolution = (datainfo.unpack 'H40LdddH*')[1..4]
    raise "Y-Data isn't 4 times than size read from DataInfo! Quitting." if @size != ydata.size
    raise "Size and (end - begin) / res don't match" unless (@wn_end - @wn_start) / @resolution - @size + 1 < 0.000001 # 1ppm tolerance

    @data = Array.new(@size) {[0.0, 0.0]}
    (0..@size - 1).each do |i|
      @data[i] = [@wn_start + i * @resolution, ydata[i]]
    end
  end
end


# Cross-platform way of finding an executable in the $PATH.
# Copied from https://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
# which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end