class ReportsController < ApplicationController
	before_filter :check_user_level_and_site

	def index
		@section ="Reports"
		render :layout => "landing"
	end

	def death_reports
		@section = "Death report"
		render :layout => "landing"
	end

	def amendment_reports
		@section = "Amendment report"
		render :layout => "landing"
	end

	def lost_damaged_reports
		@section = "Lost/Damaged report"
		render :layout => "landing"
	end

	def voided_reports
		@section = "Voided report"
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

		include_today = false
		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	(Date.today - 1.day).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			include_today = true
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	(Date.today - 1.day).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
				include_today = true
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	(Date.today - 1.day).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
				include_today = true
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	(Date.today - 1.day).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
				include_today = true
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	(Date.today - 1.day).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
				include_today = true
			end
		end
		data = {}
		if params[:start_date].present?
			start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	DateTime.parse(params[:end_date]).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			today = Time.now.strftime("%Y-%m-%d")	
			if end_date > 
				include_today = true
				(end_date.to_date - 1.day).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
				include_today = true
			end
		end
		if include_today
			data["today_data"] = today_data
		end
		#data = PersonRecordStatus.by_district_code_and_status_and_created_at.startkey([User.current_user.district_code,status_map[params[:status]],start_date]).endkey([User.current_user.district_code,status_map[params[:status]],end_date]).each

		gender = ["Female","Male"]

		gender.each do |g|
			query = "SELECT count(person_id) as count, gender , status, person_record_status.created_at , person_record_status.updated_at 
					 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 WHERE status = '#{status_map[params[:status]]}' AND gender = '#{g}' 
					 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}'
					 GROUP BY status,gender"

			count_row = SQLSearch.query_exec(query).split("\n")[1]
			
			if count_row.present?
				data[g.downcase] = count_row.split("\s")[0]
			else
				data[g.downcase] = 0
			end
		end

		render :text => data.to_json
	end

	def voided_report_data
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
		data = Person.by_district_code_and_voided_date.startkey([User.current_user.district_code,start_date]).endkey([User.current_user.district_code,end_date]).each
		male = 0
		female = 0
		data.each do |record|
			if record.gender == "Male"
				male = male + 1
			else
				female = female + 1
			end
		end
		render :text => {:male => male , :female=>female }.to_json
	end

	def lost_damaged_report_data
		male = 0
		female = 0
		render :text => {:male => male , :female=>female }.to_json
	end

	def amendment_report_data
		male = 0
		female = 0
		render :text => {:male => male , :female=>female }.to_json
	end

	def pick_dates
		@url = params[:url]
		render :layout => "touch"
	end

	def today_data
		start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
		end_date =	Time.now.strftime("%Y-%m-%dT23:59:59.999Z")
		data_today = []
		PersonRecordStatus.by_created_at.startkey(start_date).endkey(end_date).each do |s|
			person = s.person
			data_today << { id: person.id , gender: person.gender , status: s.status , created_at: s.created_at, updated_at: s.updated_at }
		end
		return data_today
	end
end
