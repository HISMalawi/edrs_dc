class Pusher2 
    def self.push(params)
        url = "#{SYNC_SETTINGS[:hq][:protocol]}://#{SYNC_SETTINGS[:hq][:host]}:3001/api/v1/dc_sync"
        RestClient.post url, params.to_json, {content_type: :json, accept: :json}
    end
end