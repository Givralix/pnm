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
							puts data[current_byte+i].chr.to_i
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
			# if maxval > 255 then the values need to be stored in a Array(UInt16) array
			@data = Array(UInt16 | UInt8).new
			if @maxval > 255
				#current_byte += 1
				while current_byte < data.size
					@data << data[current_byte].to_u16 + data[current_byte+1].to_u16
					current_byte += 2
				end
			else
				#current_byte += 1
				while current_byte < data.size
					@data << data[current_byte]
					current_byte += 1
				end
			end
		end

		def initialize(width : Int32, height : Int32, maxval : Int32, data : Array(UInt8 | UInt16))
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
			if new_maxval < 255
				0.upto(@data.size-1) do |i|
					@data[i] = (@data[i].to_u * new_maxval / @maxval).to_u8
				end
			else
				0.upto(@data.size-1) do |i|
					@data[i] = (@data[i].to_u * new_maxval / @maxval).to_u16
				end
			end
			@maxval = new_maxval
		end

		def write(filename)
			result = Array(UInt8 | UInt16).new
			if @maxval > 255 # if maxval > 255, each color is encoded on 2 bytes
				@data.each do |word|
					result << (word.bit(4) + word.bit(5)*2 + word.bit(6)*4 + word.bit(7)*8).to_u8
					result << (word.bit(0) + word.bit(1)*2 + word.bit(2)*4 + word.bit(3)*8).to_u8
				end
			else
				result = @data
			end

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
	end
end

