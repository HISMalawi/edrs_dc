require "net/http"
class RemotedPusher
    def self.model_map
        return {
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
                    "OtherSignificantCause" => "other_significant_cause_id"
                }
    end

    def self.handle_push_fail(params)
        connection = ActiveRecord::Base.connection
        model_map = self.model_map
        type = params["type"]
        query = "SELECT * FROM push_sync_tracker WHERE record_id ='#{params[model_map[type]]}' AND sync_status=0;"
        push_record = connection.select_all(query).as_json
        if push_record.count == 0
            insert_query = "INSERT INTO  push_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                            VALUES('#{params[model_map[type]]}','#{type}',0,'#{SETTINGS['district_code']}', NOw(),NOW());"
            SimpleSQL.query_exec(insert_query)
        end

    end

    def self.push(params)
            connection = ActiveRecord::Base.connection
            model_map = self.model_map
            
       
            #begin 
            if SETTINGS["site_type"] == "facility"
                    url = "#{SYNC_SETTINGS[:dc][:protocol]}://#{SYNC_SETTINGS[:dc][:host]}:#{SYNC_SETTINGS[:dc][:port]}/"
            else
                    url = "#{SYNC_SETTINGS[:hq][:protocol]}://#{SYNC_SETTINGS[:hq][:host]}:#{SYNC_SETTINGS[:hq][:port]}/"
            end
            url = URI.parse(url)
            req = Net::HTTP.new(url.host, url.port)
            res = req.request_head(url.path)
            puts "#{url}api/v1/dc_sync"

            if ["200","201","202","204","302"].include?(res.code.to_s)
                    url = "#{url}api/v1/dc_sync"

                    
                    response = RestClient.post url, {"data" => params}.to_json, {content_type: :json, accept: :json}
                    response_data = JSON.parse(response)

                    type = response_data["data"]["type"]

                    query = "SELECT * FROM push_sync_tracker WHERE record_id ='#{response_data["data"][model_map[type]]}';"
                    push_record = connection.select_all(query).as_json

                    if  response_data["message"] =="Success"    
                        sync_status = 1
                    else
                        sync_status = 0
                    end
                    
                    if push_record.count == 0
                        insert_query = "INSERT INTO  push_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                                        VALUES('#{response_data["data"][model_map[type]]}','#{type}',#{sync_status}, '#{SETTINGS['district_code']}', NOw(),NOW());"
                    else
                        insert_query = "UPDATE push_sync_tracker SET sync_status = #{sync_status} WHERE record_id='#{response_data["data"][model_map[type]]}';"
                    end
                    SimpleSQL.query_exec(insert_query)
            else
                    self.handle_push_fail(params)
            end
    end
    
end