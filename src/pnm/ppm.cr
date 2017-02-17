module PNM
	class PNM::PPM
		def initialize(data : Array(UInt8))
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

		def +(other : self)
			if other.data.size <= @data.size
				size = other.data.size
			else
				size = @data.size
			end
			width = @width
			if @height < other.height 
				height = @height
			else
				height = other.height
			end
			maxval = @maxval
			puts "width: #{width}"
			puts "height: #{height}"
			puts "maxval: #{maxval}"

			result = Array(UInt8 | UInt16).new
			0.upto(size-1) do |i|
				result << @data[i] + other.data[i]
			end
			return PNM::PPM.new(width, height, maxval, result)
		end
	end
end
