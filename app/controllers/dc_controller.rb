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
                                  :creator => User.current_user.id})


				 redirect_to "#{params[:next_url].to_s}"


		else
				status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

				status.update_attributes({:voided => true})

				PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC INCOMPLETE",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id})

				redirect_to "/people/view/#{params[:id]}?next_url=#{params[:next_url]}&topic=Completeness Check&error=Record not complete"
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
                                  :status => "DC APPROVED",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id})

				person.update_attributes({:approved =>"Yes"})

				PersonIdentifier.assign_den(person)

				Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC APPROVED",
							:level => "Person",
							:reason => "Approve record"})

			    redirect_to "#{params[:next_url].to_s}"

		else
				status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

				status.update_attributes({:voided => true})

				PersonRecordStatus.create({
                                  :person_record_id => person.id.to_s,
                                  :status => "DC INCOMPLETE",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id})
				Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC INCOMPLETE",
							:level => "Person",
							:reason => "Approve record not successful"})

				redirect_to "/people/view/#{params[:id]}?next_url=#{params[:next_url]}&topic=Can not approve Record&error=Record not complete"
		end
		
	end

	def add_rejection_comment

		
	end

	def reject_record

			status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

			status.update_attributes({:voided => true})

			PersonRecordStatus.create({
                                  :person_record_id => params[:id].to_s,
                                  :status => "DC REJECTED",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id})

			
			Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC REJECT",
							:level => "Person",
							:reason => params[:reason]})

			redirect_to "#{params[:next_url].to_s}"


	end
	def mark_as_pending

		status = PersonRecordStatus.by_person_recent_status.key(params[:id]).last

		status.update_attributes({:voided => true})

		PersonRecordStatus.create({
                                  :person_record_id => params[:id].to_s,
                                  :status => "DC PENDING",
                                  :district_code => CONFIG['district_code'],
                                  :creator => User.current_user.id})

		Audit.create({
							:record_id => params[:id].to_s    , 
							:audit_type=>"DC PENDING",
							:level => "Person",
							:reason => "Mark record as pending"})

		redirect_to "#{params[:next_url].to_s}"

		
	end

	def  approved_cases

		@section ="Approved Cases"

		@status = "DC APPROVED"

		render :template =>"/dc/dc_view_cases"
		
	end

	def rejected_cases

		@section = "Rejected Cases"

		@status = "DC REJECTED"

		render :template =>"/dc/dc_view_cases"
		
	end
	def voided

		@section = "voided Records"

		@status = "HQ VOIDED"

		render :template =>"/dc/dc_view_cases"
		
	end

	def closed

		@section = "Printed Records"

		@status = "HQ CLOSED"

		render :template =>"/dc/dc_view_cases"
		
	end

	def dispatched

		@section = "Dispatched"

		@status = "HQ DISPATCHED"

		render :template =>"/dc/dc_view_cases"
		
	end

	def pending_cases
		
		@section = "Pending Record"

		@status = "DC PENDING"

		render :template =>"/dc/dc_view_cases"

	end

	def manage_duplicates

		@section = "Manage Duplicates"
		
	end

	def counts_by_status

		status = params[:status]

		if status == "REPORTED"

			count = Person.count

		else

			count = PersonRecordStatus.by_record_status.key(status).each.count

		end

		render :text => {:count => count}.to_json
		
	end

	protected

	
end
