require "net/http"
class RemotedPusher
    def self.push(params)
        
        model_map ={
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
            "OtherSignificantCauseRecord" => "other_significant_cause_id"
        }

       
            begin 
                url = "#{SYNC_SETTINGS[:hq][:protocol]}://#{SYNC_SETTINGS[:hq][:host]}:3001/"
                url = URI.parse(url)
                req = Net::HTTP.new(url.host, url.port)
                res = req.request_head(url.path)
                puts "#{url}api/v1/dc_sync"

                if ["200","201","202","204","302"].include?(res.code.to_s)
                    url = "#{url}api/v1/dc_sync"
                    response = RestClient.post url, {"data" => params}.to_json, {content_type: :json, accept: :json}
                    response_data = JSON.parse(response)

                    type = response_data["data"]["type"]

                    if  response_data["message"] =="Success"    
                        insert_query = "INSERT INTO  push_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                        VALUES('#{response_data["data"][model_map[type]]}','#{type}',
                        1, '#{SETTINGS['district_code']}', NOw(),NOW());"
                    else
                        insert_query = "INSERT INTO  push_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                        VALUES('#{response_data["data"][model_map[type]]}','#{type}',
                        0, '#{SETTINGS['district_code']}', NOw(),NOW());"
                    end

                    SimpleSQL.query_exec(insert_query)
                else
                    type = params["data"]["type"]
                    insert_query = "INSERT INTO  push_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                    VALUES('#{params["data"][model_map[type]]}','#{type}',
                    0, '#{SETTINGS['district_code']}', NOw(),NOW());"
                    SimpleSQL.query_exec(insert_query)
                end
            rescue
                type = params["type"]
                insert_query = "INSERT INTO  push_sync_tracker (record_id,type,sync_status,district_code,created_at,updated_at)
                VALUES('#{params[model_map[type]]}','#{type}',
                0, '#{SETTINGS['district_code']}', NOw(),NOW());"
                SimpleSQL.query_exec(insert_query)
            end
    end
    
end