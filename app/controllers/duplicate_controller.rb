class DuplicateController < ApplicationController
	def index
	  @facility = facility

      @district = district

      @section = "Duplicate Capturing"

      render :layout => "landing"
	end
end
