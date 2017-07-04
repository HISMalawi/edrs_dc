 LoadMysql.load_mysql = false
 require 'simple_sql'
 couch_mysql_migration_table = "CREATE TABLE IF NOT EXISTS couch_mysql_migration(migration_id INT(11)
                          NOT NULL AUTO_INCREMENT, time_of_migration  datetime NOT NULL, PRIMARY KEY (migration_id));"
 SimpleSQL.exec(couch_mysql_migration_table)
 @couchdb_files = {
      'Person' => {count: Person.count, name: 'Person doc.', id: 'person_doc', 
        doc_primary_key: 'person_id', table_name: 'people'},

      'PersonIdentifier' => {count: PersonIdentifier.count, name: 'PersonIdentifier doc.', 
        id: 'person_identifier_doc', doc_primary_key: 'person_identifier_id', table_name: 'person_identifier'},

      'PersonRecordStatus' => {count: PersonRecordStatus.count, name: 'PersonRecordStatus doc.', 
        id: 'person_record_status_doc', doc_primary_key: 'person_record_status_id', table_name: 'person_record_status'},
      
      'District' => {count: District.count, name: 'District doc.', 
        id: 'district_doc', doc_primary_key: 'district_id', table_name: 'district'},

      'Nationality' => {count: Nationality.count, name: 'Nationality doc.', 
        id: 'nationality_doc', doc_primary_key: 'nationality_id', table_name: 'nationality'},

      'Village' => {count: Village.count, name: 'Village doc.', 
        id: 'village_doc', doc_primary_key: 'village_id', table_name: 'village'},

      'TraditionalAuthority' => {count: TraditionalAuthority.count, name: 'TraditionalAuthority doc.', 
        id: 'traditional_authority_doc', doc_primary_key: 'traditional_authority_id', table_name: 'traditional_authority'},

      'User' => {count: User.count, name: 'User doc.', 
        id: 'user_doc', doc_primary_key: 'user_id', table_name: 'user'},

      'Role' => {count: Role.count, name: 'Role doc.', 
        id: 'role_doc', doc_primary_key: 'role_id', table_name: 'role'},

      'Country' => {count: Country.count, name: 'Country doc.', 
        id: 'country_doc', doc_primary_key: 'country_id', table_name: 'country'}

}

def insert_update(record,key)
    primary_key = @couchdb_files[key][:doc_primary_key]
    table_name = @couchdb_files[key][:table_name]

    check_existance_query = "SELECT #{primary_key} FROM #{table_name} WHERE #{primary_key} = '#{record.id}' LIMIT 1;"

    row = SimpleSQL.query_exec(check_existance_query).split(/\n/)

    if row[1].present?
        record_keys = record.keys.sort - ['_id','_rev','type']
        update_query = "UPDATE #{table_name} SET "
        record_keys.each do |property|
            if record_keys[0] == property
               update_query = "#{update_query} #{property} = '#{record[property].to_s.gsub("'","''")}'"
            else
                update_query = "#{update_query},#{property} = '#{record[property].to_s.gsub("'","''")}'"
            end
        end
        update_query = "#{update_query} WHERE #{primary_key} = '#{record.id}';"
        SimpleSQL.query_exec(update_query)
        puts "Record migration #{record.id} to #{table_name.humanize}"
    else
        record_keys = record.keys.sort - ['_rev','type']
        insert_query = "INSERT INTO #{table_name} ("
        record_keys.each do |property|
            
            if record_keys[0] == property
               if property =="_id"
                  property = primary_key
              end
               insert_query = "#{insert_query} #{property}"
            else
              if property =="_id"
                property = primary_key
              end
                insert_query = "#{insert_query},#{property}"
            end
        end
        insert_query = "#{insert_query}) VALUES("
        record_keys.each do |property|
            if record_keys[0] == property
               insert_query = "#{insert_query} '#{record[property].to_s.gsub("'","''")}'"
            else
                insert_query = "#{insert_query},'#{record[property].to_s.gsub("'","''")}'"
            end
        end
        insert_query = "#{insert_query});"
        SimpleSQL.query_exec(insert_query)
        puts "Record migration #{record.id} to #{table_name.humanize}"
    end
end

start_migration_time_query = "SELECT time_of_migration FROM couch_mysql_migration 
                              WHERE time_of_migration IS NOT NULL 
                              ORDER BY migration_id DESC LIMIT 1;"
data = SimpleSQL.query_exec(start_migration_time_query).split(/\n/)

start_date = (data[1] rescue "1900-01-01 00:00:00".to_time)
end_date = Time.now.strftime("%Y-%m-%d %H:%M:%S").to_time

@couchdb_files.keys.each do |key|
  eval(key).by_updated_at.startkey(start_date).endkey(end_date).each do |record|
    insert_update(record,key)
  end
end

add_migration_query = "INSERT INTO couch_mysql_migration (time_of_migration) VALUES('#{end_date}');"
SimpleSQL.exec(add_migration_query)

puts "Couch to MSQL done"

LoadMysql.load_mysql = true