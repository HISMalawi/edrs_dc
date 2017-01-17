class DeathEntryNumber < CouchRest::Model::Base

	property :number, String
	property :assigned, TrueClass, :default =>false
	property :voided, TrueClass, :default => false
	property :district_code, String

	validates_uniqueness_of :number

	timestamps!

	design do
		view :by_district_code
	end

	def self.generate_numbers(number = 20, year = Date.today.year)

			District.all.map(&:district_code).each do |code|
				1.upto(number).each do |n|
					num = n.to_s.rjust(10,"0")
					puts "#{code}/#{num}/#{year}"
					den = "#{code}/#{num}/#{year}"
					self.create({:number=>den, :district_code=>code})
				end
			end

	end
end
