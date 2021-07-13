# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

require "bantu_soundex"
require "zebra_printer"
require "visit_label"
require "csv"
require "encryption"
require "simple_sql"
require "simple_elastic_search"
require "person_service"
require "de-duplication"
require "remote_pusher"
