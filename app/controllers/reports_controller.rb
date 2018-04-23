class ReportsController < ApplicationController
	before_filter :check_user_level_and_site

	def index
		@section ="Reports"
		render :layout => "landing"
	end

	def registration_type_and_gender
		@section ="By Registration type and gender"
		@registration = ["Normal Cases","Abnormal Deaths","Dead on Arrival","Unclaimed bodies","Missing Persons","Deaths Abroad","All"]
		render :layout => "landing"
	end
	def place_of_birth_and_gender
		@section ="By place of birth and gender"
		@place_of_death =["Home","Health Facility", "Other", "All"]
		render :layout => "landing"
	end

	def by_registartion_type
		render :text => {:count=> 0 , :gender => params[:gender], :type => params[:type]}.to_json
	end

	def by_place_of_death
		render :text => {:count=> 0 , :gender => params[:gender], :place => params[:place]}.to_json
	end

	def death_reports
		@section = "Death report"
		@data = Report.general(params)
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
				"Reported" => "DC ACTIVE",
				"Registered" => "HQ ACTIVE",
				"Duplicates" => "DC DUPLICATE",
				"Printed" => "HQ CLOSED",
				"Dispatched" => "HQ DISPATCHED"
		}

		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			end
		end
		data = {}
		if params[:start_date].present?
			start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	DateTime.parse(params[:end_date]).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		end

		gender = ["Female","Male"]

		gender.each do |g|
			query = "SELECT count(person_id) as count, gender , status, person_record_status.created_at , person_record_status.updated_at 
					 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 WHERE status = '#{status_map[params[:status]]}' AND gender = '#{g}' 
					 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}'
					 GROUP BY status,gender"
			puts query
	
			count_row = SimpleSQL.query_exec(query).split("\n")[1]
			
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
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			end
		end
		data = {}
		if params[:start_date].present?
			start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	DateTime.parse(params[:end_date]).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		end

		gender = ["Female","Male"]

		gender.each do |g|
			query = "SELECT count(person_id) as count, gender FROM people 
					WHERE people.voided = 1 AND people.voided_date >= '#{start_date}' 
					AND people.voided_date <='#{end_date}' AND people.gender = '#{g}'
		 			AND people.district_code = '#{User.current_user.district_code}' GROUP BY gender"

	
			count_row = SimpleSQL.query_exec(query).split("\n")[1]
			
			if count_row.present?
				data[g.downcase] = count_row.split("\s")[0]
			else
				data[g.downcase] = 0
			end
		end

		render :text => data.to_json
	end

	def lost_damaged_report_data
		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			end
		end
		data = {}
		if params[:start_date].present?
			start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	DateTime.parse(params[:end_date]).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		end

		gender = ["Female","Male"]

		gender.each do |g|
			query = "SELECT count(person_id) as count, gender , status, person_record_status.created_at , person_record_status.updated_at 
					 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 WHERE status = 'DC REPRINT' AND gender = '#{g}' 
					 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}'
					 GROUP BY status,gender"
	
			count_row = SimpleSQL.query_exec(query).split("\n")[1]
			
			if count_row.present?
				data[g.downcase] = count_row.split("\s")[0]
			else
				data[g.downcase] = 0
			end
		end

		render :text => data.to_json
	end

	def amendment_report_data
		if params[:timeline].blank?
			start_date = Time.now.strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		else
			case params[:timeline]
			when "Today"
				start_date = Time.now.strftime("%Y-%m-%dT00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current week"
				start_date = Time.now.beginning_of_week.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current month"
				start_date = Time.now.beginning_of_month.strftime("%Y-%m-%d 00:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			when "Current year"
				start_date = Time.now.beginning_of_year.strftime("%Y-%m-%d 0:00:00:000Z")
				end_date =	Date.today.to_time.strftime("%Y-%m-%d 23:59:59.999Z")
			end
		end
		data = {}
		if params[:start_date].present?
			start_date = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d 00:00:00:000Z")
			end_date =	DateTime.parse(params[:end_date]).to_time.strftime("%Y-%m-%d 23:59:59.999Z")
		end

		gender = ["Female","Male"]

		gender.each do |g|
			query = "SELECT count(person_id) as count, gender , status, person_record_status.created_at , person_record_status.updated_at 
					 FROM people INNER JOIN person_record_status ON people.person_id  = person_record_status.person_record_id
					 WHERE status = 'DC AMEND' AND gender = '#{g}' 
					 AND person_record_status.district_code = '#{User.current_user.district_code}' 
					 AND person_record_status.created_at >= '#{start_date}' AND person_record_status.created_at <='#{end_date}'
					 GROUP BY status,gender"

			count_row = SimpleSQL.query_exec(query).split("\n")[1]
			
			if count_row.present?
				data[g.downcase] = count_row.split("\s")[0]
			else
				data[g.downcase] = 0
			end
		end

		render :text => data.to_json
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
