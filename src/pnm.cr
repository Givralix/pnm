require "./pnm/*"

module PNM
	def self.datatype?(data : Array(UInt8))
		magic_number = data[0].chr + data[1].chr
		dictionnary = {"P4" => "PBM", "P5" => "PGM", "P6" => "PPM", "P7" => "PAM"}
		begin
			dictionnary[magic_number]
		rescue KeyError
			puts "Data type not supported"
			nil
		end
	end
end
