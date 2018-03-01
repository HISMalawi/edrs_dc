require 'simple_sql'
if Rails.env == "development"
     puts Person.count
     Person.all.each do |d|
        d.destroy
     end

     puts PersonRecordStatus.count

     PersonRecordStatus.all.each do |d|
        d.destroy
     end

     puts PersonIdentifier.count

     PersonIdentifier.all.each do |d|
        d.destroy  
     end

     Sync.all.each do |d|
        d.destroy
     end

     SETTING = YAML.load_file("#{Rails.root}/config/elasticsearchsetting.yml")['elasticsearch']
     puts `curl -XDELETE #{SETTING['host']}:#{SETTING['port']}/#{SETTING['index']}`

     sql = "SET FOREIGN_KEY_CHECKS = 0;"
     SimpleSQL.query_exec(sql)

        create_status_table = "DELETE FROM  person_record_status WHERE person_record_id IS NOT NULL;"
        SimpleSQL.query_exec(create_status_table); 

         puts "Drop person_record_status"  

        create_identifier_table = "DELETE FROM person_identifier WHERE identifier IS NOT NULL;"  
                                
        SimpleSQL.query_exec(create_identifier_table);

        puts "Drop person_record_status"   

        create_people_table = "SET FOREIGN_KEY_CHECKS = 0;
                              DELETE FROM people WHERE person_id IS NOT NULL ;
                              SET FOREIGN_KEY_CHECKS = 1;"
    SimpleSQL.query_exec(create_people_table)    

end
