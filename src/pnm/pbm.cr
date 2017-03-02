module PNM
	class PNM::PBM
		def data
			@data
		end

		def height
			@height
		end

		def initialize(data : Slice(UInt8))
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
			@data = data[current_byte, data.size-current_byte]

		end

		def initialize(@width : Int32, @height : Int32, @data : Slice(UInt8))
		end
		
		def to_pgm(maxval : Int32)
			result = Slice(UInt8).new(@data.size*8)
			0.upto(@data.size-1) do |i|
				0.upto(7) do |bit|
					new_byte = 0_u8
					if @data[i].bit(7-bit) == 0
						new_byte = maxval.to_u8
					end
					result[i*8+bit] = new_byte
				end
			end
			PNM::PGM.new(@width, @height, maxval, result)
		end
		
		def to_pgm
			self.to_pgm(255)
		end

		def to_ppm(maxval : Int32)
			self.to_pgm(maxval).to_ppm
		end

		def to_ppm
			self.to_ppm(255)
		end

		def width
			@width
		end

		def write(filename : String)
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
				file.write(@data)
			end
		end
		
		def +(other : self)
			result = Slice(UInt8).new(width*height/8)
			
			0.upto(result.size-1) do |i|
				byte = @data[i].to_u + other.data[i].to_u
				if byte > 255
					result[i] = 255_u8
				else
					result[i] = byte.to_u8
				end
			end
			PNM::PBM.new(width, height, result)
		end

		def -(other : self)
			result = Slice(UInt8).new(width*height/8)
			
			0.upto(result.size-1) do |i|
				byte = @data[i].to_i - other.data[i].to_i
				if byte < 0
					result[i] = 0_u8
				else
					result[i] = byte.to_u8
				end
			end
			PNM::PBM.new(width, height, result)
		end

		def *(other : self)
			result = Slice(UInt8).new(width*height/8)
			
			0.upto(result.size-1) do |i|
				byte = (@data[i].to_u * other.data[i].to_u)/255
				if byte > 255
					result[i] = 255_u8
				else
					result[i] = byte.to_u8
				end
			end
			PNM::PBM.new(width, height, result)
		end

		def /(other : self)
			result = Slice(UInt8).new(width*height/8)
			
			0.upto(result.size-1) do |i|
				if other.data[i] != 0
					byte = @data[i].to_i * 255 / other.data[i].to_i
					if byte > 255
						result[i] = 255_u8
					else
						result[i] = byte.to_u8
					end
				else
					result[i] = 255_u8
				end
			end
			PNM::PBM.new(width, height, result)
		end

		def invert()
			result = Slice(UInt8).new(width*height/8)

			0.upto(result.size-1) do |i|
				result[i] = 255_u8 - @data[i]
			end
			PNM::PBM.new(width, height, result)
		end
	end
end
