class ReportsController < ApplicationController
	def index
		@section ="Reports"
		render :layout => "landing"
	end

	def death_reports
		@section = "Death report"
		render :layout => "landing"
	end

	def report_data
		status_map ={
				"Reported" => "NEW",
				"Registered" => "DC APPROVED",
				"Duplicates" => "DC DUPLICATE",
				"Printed" => "HQ CLOSED",
				"Dispatched" => "HQ DISPATCHED"
		}


		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
			end_date =	Time.now.strftime("%Y-%m-%dT23:59:59.999Z")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Time.now.strftime("%Y-%m-%dT23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Time.now.strftime("%Y-%m-%dT23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Time.now.strftime("%Y-%m-%dT23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Time.now.strftime("%Y-%m-%dT23:59:59.999Z")
			end
		end

		if params[:start_date].present?
			start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%dT00:00:00:000Z")
			end_date =	DateTime.parse(params[:end_date]).strftime("%Y-%m-%dT23:59:59.999Z")
		end

		data = PersonRecordStatus.by_status_and_created_at.startkey([status_map[params[:status]],start_date]).endkey([status_map[params[:status]],end_date]).each
		male = 0
		female = 0
		data.each do |record|
			if record.person.gender == "Male"
				male = male + 1
			else
				female = female + 1
			end
		end
		render :text => {:male => male , :female=>female }.to_json
	end

	def pick_dates
		render :layout => "touch"
	end
end
