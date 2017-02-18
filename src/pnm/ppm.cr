module PNM
	class PNM::PPM
		def blue
			result = Slice(UInt8).new(@data.size/3)
			0.upto(@data.size/3-1) do |i|
				result[i] = @data[i*3+2]
			end
			PNM::PGM.new(@width, @height, @maxval, result)
		end

		def data
			@data
		end

		def green
			result = Slice(UInt8).new(@data.size/3)
			0.upto(@data.size/3-1) do |i|
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
			0.upto(@data.size-1) do |i|
				@data[i] = (@data[i].to_u * new_maxval / @maxval).to_u8
			end
			@maxval = new_maxval
		end

		def red
			result = Slice(UInt8).new(@data.size/3)
			0.upto(@data.size/3-1) do |i|
				result[i] = @data[i*3]
			end
			PNM::PGM.new(@width, @height, @maxval, result)
		end

		def to_pbm
			self.to_pbm(128)
		end
		
		def to_pbm(threshold : Int32)
			self.to_pgm.to_pbm(threshold)
		end

		def to_pgm
			result = Slice(UInt8).new(@data.size/3)
			0.upto(@data.size/3-1) do |i|
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
	end
end
