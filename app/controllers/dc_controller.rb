class DcController < ApplicationController

	before_filter :facility_info

	def index

	  @facility = facility

      @district = district

      @section = "Home"

      render :layout => "dc"
		
	end

	def check_completeness

		person = Person.find(params[:id])

		if record_complete?(person)

				status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

				status.update_attributes({:voided => true})

				PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC COMPLETE",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id});

				 render :text => {:response => "Complete" , :person =>person}.to_json


		else

				render :text => {:response => "Incomplete" , :person =>person}.to_json

		end
		
	end


	def manage_cases

		@section = "Manage Cases"
		
	end


	def approve_cases

		@section ="Approve Cases"
	
	end

	def approve_record

		person = Person.find(params[:id])

		if record_complete?(person)

				status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

				status.update_attributes({:voided => true})

				PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC APPROVE",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id});

				 redirect_to '/dc/approve_cases'


		else

				render :text => {:response => "Not approved" , :person =>person}.to_json

		end
		
	end

	protected

	
end
