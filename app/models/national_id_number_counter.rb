require 'couchrest_model'
require 'thread'

class NationalIdNumberCounter < CouchRest::Model::Base

  use_database "local"

  cattr_accessor :mutex

  property :auto_increment_count, Integer, :default => 0

  timestamps!

  def self.assign_serial_number(child,facility_code)

    return false if (child.class.name.to_s.downcase != "person" rescue true)

    @mutex = Mutex.new if @mutex.blank?

    t = Thread.new do

      @mutex.lock

      counter = self.by_last_assigned.each.first

      counter = self.create(:auto_increment_count => 0) if counter.nil?

      next_number = counter.auto_increment_count + 1

      @mutex.unlock if !child.facility_serial_number.blank?

      return false if !child.facility_serial_number.blank?

      counter.update_attributes(:auto_increment_count => next_number)

      id = "%06d" % next_number

      check_digit = self.calculate_check_digit(next_number)

      npid = "P5#{facility_code}#{id}#{check_digit}"

      NationalIdNumber.create(:facility_serial_number_value => next_number,
      												:district_id => CONFIG["district_code"],
      												:facility_serial_number => npid)
      
      child.update_attributes(:facility_serial_number => npid)

      @mutex.unlock

      return true

    end

  end

  def self.calculate_check_digit(serial_number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    number = serial_number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      digit = digit * 2 if index%2!=parity
      digit = digit - 9 if digit > 9
      sum = sum + digit
    end

    check_digit = (9 * sum) % 10

    return check_digit
  end

  design do
    view :by_last_assigned,
         :map => "function(doc) {
                  if ((doc['type'] == 'NationalIdNumberCounter')) {
                    emit(doc['auto_increment_count'], 1);
                  }
                }"
  end

end
