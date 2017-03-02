module PNM
	class PNM::PPM
		def blue
			result = Slice(UInt8).new(@data.size/3)
			result.each_index do |i|
				result[i] = @data[i*3+2]
			end
			PNM::PGM.new(@width, @height, @maxval, result)
		end

		def data
			@data
		end

		def green
			result = Slice(UInt8).new(@data.size/3)
			result.each_index do |i|
				result[i] = @data[i*3+1]
			end
			PNM::PGM.new(@width, @height, @maxval, result)
		end

		def height
			@height
		end

		def initialize(data : Slice(UInt8))
			if PNM.datatype?(data) != "PPM"
				raise Exception.new("Not a PPM file")
			end
			
			current_byte = 3

			@width = 0
			@height = 0
			@maxval = 0
			# looping through the file's header
			loop do
				# checking if there is a comment
				if data[current_byte] == 0x23
					until data[current_byte] == 0x0a # until the comment reaches its end, ignore
						current_byte += 1
					end
				end
				
				# checking if it's a number
				if data[current_byte].chr.number?
					if @width == 0
						power = 0
						while data[current_byte+power].chr.number?
							power += 1
						end
						power = power - 1
						0.upto(power) do |i|
							@width += data[current_byte+i].chr.to_i * 10**(power-i)
						end
						current_byte += power
					elsif @height == 0
						power = 0
						while data[current_byte+power].chr.number?
							power += 1
						end
						power = power - 1
						0.upto(power) do |i|
							@height += data[current_byte+i].chr.to_i * 10**(power-i)
						end
						current_byte += power
					else
						power = 0
						while data[current_byte+power].chr.number?
							power += 1
						end
						power = power - 1
						0.upto(power) do |i|
							@maxval += data[current_byte+i].chr.to_i * 10**(power-i)
						end
						current_byte += power
					end
				end
				
				current_byte += 1
				# once the program has gotten all the values it needs
				break if @width != 0 && @height != 0 && @maxval != 0
			end
			
			current_byte += 1
			@data = data[current_byte, data.size-current_byte]
		end

		def initialize(@width : Int32, @height : Int32, @maxval : Int32, @data : Slice(UInt8))
		end

		def maxval
			@maxval
		end

		def maxval=(new_maxval : Int32)
			@data.each_index do |i|
				@data[i] = (@data[i].to_u * new_maxval / @maxval).to_u8
			end
			@maxval = new_maxval
		end

		def red
			result = Slice(UInt8).new(@data.size/3)
			result.each_index do |i|
				result[i] = @data[i*3]
			end
			PNM::PGM.new(@width, @height, @maxval, result)
		end

		def to_pbm
			to_pbm(128)
		end
		
		def to_pbm(threshold : Int32)
			to_pgm.to_pbm(threshold)
		end

		def to_pgm
			result = Slice(UInt8).new(@data.size/3)
			result.each_index do |i|
				byte = ((@data[i*3].to_u + @data[i*3+1] + @data[i*3+1])/3).to_u8
				result[i] = byte
			end
			PNM::PGM.new(@width, @height, @maxval, result)
		end

		def width
			@width
		end

		def write(filename : String)
			result = @data

			File.open(filename, "wb") do |file|
				# magic number (P6 for PPM)
				file.write_byte('P'.ord.to_u8)
				file.write_byte('6'.ord.to_u8)
				file.write_byte(0x0a.to_u8)
				# width
				width.to_s.each_char do |char|
					file.write_byte(char.ord.to_u8)
				end
				file.write_byte(0x0a.to_u8)
				# height
				height.to_s.each_char do |char|
					file.write_byte(char.ord.to_u8)
				end
				file.write_byte(0x0a.to_u8)
				# maximum value
				maxval.to_s.each_char do |char|
					file.write_byte(char.ord.to_u8)
				end
				file.write_byte(0x0a.to_u8)

				# picture data
				file.write(result)
			end
		end

		def +(other : self)
			result = Slice(UInt8).new(width*height*3)

			home = dup
			
			result.each_index do |i|
				byte = home.data[i].to_u + other.data[i].to_u
				if byte > maxval
					result[i] = maxval.to_u8
				else
					result[i] = byte.to_u8
				end
			end
			PNM::PPM.new(width, height, maxval, result)
		end

		def -(other : self)
			result = Slice(UInt8).new(width*height*3)

			home = dup
			
			result.each_index do |i|
				byte = home.data[i].to_i - other.data[i].to_i
				if byte < 0
					result[i] = 0_u8
				else
					result[i] = byte.to_u8
				end
			end
			PNM::PPM.new(width, height, maxval, result)
		end

		def *(other : self)
			result = Slice(UInt8).new(width*height*3)

			home = dup
			
			result.each_index do |i|
				byte = (home.data[i].to_u * other.data[i].to_u)/maxval
				if byte > maxval
					result[i] = maxval.to_u8
				else
					result[i] = byte.to_u8
				end
			end
			PNM::PPM.new(width, height, maxval, result)
		end

		def /(other : self)
			result = Slice(UInt8).new(width*height*3)

			home = dup
			
			result.each_index do |i|
				if other.data[i] != 0
					byte = home.data[i].to_i * maxval / other.data[i].to_i
					if byte > maxval
						result[i] = maxval.to_u8
					else
						result[i] = byte.to_u8
					end
				else
					result[i] = maxval.to_u8
				end
			end
			PNM::PPM.new(width, height, maxval, result)
		end
		
		# probably doesnt work but eh
		def crop(new_width : Int32, new_height : Int32)
			result = Slice(UInt8).new(new_width*new_height)
			
			0.upto(new_height-1) do |y|
				0.upto(new_width-1) do |i|
					result[y*new_width+i] = @data[y*@width+i]
				end
			end

			@width = new_width
			@height = new_height
			@data = result
			nil
		end

		# takes 3 PGM objects as red, green and blue channels and outputs 1 PPM object
		def initialize(red : PNM::PGM, green : PNM::PGM, blue : PNM::PGM)
			result = Slice(UInt8).new(red.data.size*3)

			result.each_index do |i|
				if i % 3 == 0
					result[i] = red.data[i/3]
				elsif i % 3 == 1
					result[i] = green.data[i/3]
				else
					result[i] = blue.data[i/3]
				end
			end
			@width = red.width
			@height = red.height
			@maxval = red.maxval
			@data = result
		end
		
		def invert()
			result = Slice(UInt8).new(@width*@height*3)

			0.upto(result.size-1) do |i|
				result[i] = 255_u8 - @data[i]
			end
			PNM::PPM.new(@width, @height, @maxval, result)
		end
	end
end
