class ApiController < ApplicationController
    def model_map
        models ={
            "UserModel" =>"user_id",
            "Record" => "person_id",
            "RecordIdentifier" => "person_identifier_id",
            "RecordStatus" => "person_record_status_id",
            "VillageRecord"=> "village_id",
            "TA" =>"traditional_authority_id",
            "DistrictRecord" =>" district_id",
            "CountryRecord" => "country_id",
            "NationalityRecord"=>"nationality_id",
            "BarcodeRecord" => "barcode_id",
            "PersonICDCode" =>"person_icd_code_id",
            "OtherSignificantCause" => "other_significant_cause_id",
            "AuditPersonRecord" => "audit_person_id"
        }
        return models
    end
    def verify_certificate
        #raise RecordIdentifier.where(identifier: params[:den]).last.inspect
        render :text => PersonService.verify_record(params).to_json and return
    end

    def dc_sync

        data = params[:data]
        record = eval(data["type"]).where("#{model_map[data["type"]]}='#{data[model_map[data["type"]]]}'").first rescue nil

        record = eval(data["type"]).new if record.blank?
        
        data.keys.each do |key|
            next if key =="type"
            record[key] = data[key]
        end
        
        if record.save
            render :text => {:data =>data, :message => "Success"}.to_json and return
        else
            render :text => {:data =>data, :message => "Fail to Save"}.to_json and return
        end
    end

    def hq_sync
        connection = ActiveRecord::Base.connection
        query = "SELECT * FROM pull_sync_tracker WHERE sync_status = 0 AND district_code='#{params[:district_code]}' ORDER BY created_at LIMIT 100;"
        hq_changes = (connection.select_all(query).as_json rescue [])
        render :text => hq_changes.to_json and return 
    end
    def get_remote_record
        type = params[:type]
        record = eval(type).find(params[:record_id]) rescue {}
        render :text=> record.to_json and return
    end
    def update_sync_status
        update_query = "UPDATE pull_sync_tracker SET sync_status = 1 WHERE record_id='#{params['record_id']}'"
        SimpleSQL.query_exec(update_query)
        render :text =>"Done" and return
    end
end