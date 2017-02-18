module PNM
	class PNM::PGM
		def initialize(data : Array(UInt8))
			if PNM.datatype?(data) != "PGM"
				raise Exception.new("Not a PGM file")
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
			@data = data[current_byte...data.size]
		end

		def initialize(width : Int32, height : Int32, maxval : Int32, data : Array(UInt8))
			@width = width
			@height = height
			@maxval = maxval
			@data = data
		end

		def width
			@width
		end

		def height
			@height
		end

		def maxval
			@maxval
		end

		def data
			@data
		end

		def maxval=(new_maxval)
			0.upto(@data.size-1) do |i|
				@data[i] = (@data[i].to_u * new_maxval / @maxval).to_u8
			end
			@maxval = new_maxval
		end

		def write(filename)
			result = @data

			File.open(filename, "wb") do |file|
				# magic number (P5 for PGM)
				file.write_byte('P'.ord.to_u8)
				file.write_byte('5'.ord.to_u8)
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
				result.each do |byte|
					file.write_byte(byte.to_u8)
				end
			end
		end
		
		def to_ppm
			result = Array(UInt8).new
			@data.each do |byte|
				1.upto(3) do
					result << byte
				end
			end
			PNM::PPM.new(@width, @height, @maxval, result)
		end

		def to_pbm(threshold)
			result = Array(UInt8).new
			0.upto(@data.size/8-1) do |i|
				new_byte = 0_u8
				0.upto(7) do |j|
					new_byte = new_byte << 1
					if @data[i*8+j] <= threshold
						new_byte += 1
					end
				end
				result << new_byte
			end
			PNM::PBM.new(@width, @height, result)
		end

		def to_pbm
			self.to_pbm(@maxval/2)
		end
	end
end

