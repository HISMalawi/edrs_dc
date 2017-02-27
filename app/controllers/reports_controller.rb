class ReportsController < ApplicationController
	def index
		@section ="Reports"
		render :layout => "landing"
	end
end
