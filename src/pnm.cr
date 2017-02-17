require "./pnm/*"

module PNM
	# Returns the file's datatype (returns nil if not supported by this module)
	def self.datatype?(data : Array(UInt8))
		magic_number = data[0].chr.to_s + data[1].chr.to_s
		dictionnary = {"P4" => "PBM", "P5" => "PGM", "P6" => "PPM", "P7" => "PAM"}
		begin
			dictionnary[magic_number]
		rescue KeyError
			puts "Data type not supported"
			nil
		end
	end
end
