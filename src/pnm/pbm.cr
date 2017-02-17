module PNM
	class PNM::PBM
		def initialize(data : Array(UInt8))
			if PNM.datatype?(data) != "PBM"
				raise Exception.new("Not a PBM file")
			end
			
			current_byte = 3

			@width = 0
			@height = 0
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
					else
						power = 0
						while data[current_byte+power].chr.number?
							power += 1
						end
						power = power - 1
						0.upto(power) do |i|
							@height += data[current_byte+i].chr.to_i * 10**(power-i)
						end
						current_byte += power
					end
				end
				
				current_byte += 1
				# once the program has gotten all the values it needs
				break if @width != 0 && @height != 0
			end
			
			current_byte += 1
			@data = Array(UInt8).new
			while current_byte < data.size
				@data << data[current_byte]
				current_byte += 1
			end
		end

		def initialize(width : Int32, height : Int32, data : Array(UInt8))
			@width = width
			@height = height
			@data = data
		end

		def width
			@width
		end

		def height
			@height
		end

		def data
			@data
		end

		def write(filename)
			result = @data.dup

			File.open(filename, "wb") do |file|
				# magic number (P4 for PBM)
				file.write_byte('P'.ord.to_u8)
				file.write_byte('4'.ord.to_u8)
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

				# picture data
				result.each do |byte|
					file.write_byte(byte.to_u8)
				end
			end
		end
	end
end


