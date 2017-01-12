class DcController < ApplicationController

	def index

	  @facility = facility

      @district = district

      @section = "Home"

      render :layout => "dc"
		
	end
end
