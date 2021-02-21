# Jasco_jws
## This is a tiny function that
- Opens a JASCO IR .jws file, and
- Extracts the spectrum parameter and content, then
- Packs it in a JWSFile object

## Requirement
- Ruby
- ruby-ole

## Usage
  Simply lazily:
  ```ruby
  require './lib.rb'
  jws = JWSFile.new <path_to_jws_file>
  
  #Here goes your array of [wavenumber, %T] data
  jws.data
  ```

## Notes on where the informations are
  The jws file is in form of a COM structured storage / OLE Storage. The spectrum y values are stored in ./Y-Data in 32-bit floats. The x values had to be constructed from the starting wavenumber, ending wavenumber and spectral resolution. All three, with the addition of number of points in spectrum can be found in ./DataInfo in the following format:
```
<leading 20 bits of constant mystery>
<Number of points (32-bit int)>
<Starting wavenumber (64-bit float)>
<Ending wavenumber (64-bit float)>
<Spectral spacing between two points (64-bit float)>
<And 48 bits more mystery>
```
