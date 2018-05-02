require "rails"
require 'simple_sql'

 sql = "SET FOREIGN_KEY_CHECKS = 0;"
 SimpleSQL.query_exec(sql)

create_query = "CREATE TABLE IF NOT EXISTS documents (
                    id int(11) NOT NULL AUTO_INCREMENT,
                    couchdb_id varchar(255) NOT NULL UNIQUE,
                    group_id varchar(255) DEFAULT NULL,
                    group_id2 varchar(255) DEFAULT NULL,
                    date_added datetime DEFAULT NULL,
                    title TEXT,
                    content TEXT,
                    created_at datetime NOT NULL,
                    updated_at datetime NOT NULL,
                    PRIMARY KEY (id),
                    FULLTEXT KEY content (content)
                  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
  SimpleSQL.query_exec(create_query);

 PersonIdentifier.can_assign_den = false
 @@file_path = "#{Rails.root.to_s}/db/MySQL_data/"
 Dir.mkdir(@@file_path) unless Dir.exist?(@@file_path)
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
def create_file(doc_primary_key, doc, table_name)
    #Create insert statments for all documets
    #Ducument path: app/assets/data/MySQL_data/
    
    if doc_primary_key.blank?
      doc_primary_key = 'id'
      person_table = <<EOF
        DROP TABLE IF EXISTS `#{table_name}`;
        CREATE TABLE `#{table_name}` (
        `#{doc_primary_key}` INT(11)  NOT NULL AUTO_INCREMENT,
EOF
    
    else
      person_table = <<EOF
        DROP TABLE IF EXISTS `#{table_name}`;
        CREATE TABLE `#{table_name}` (
        `#{doc_primary_key}` VARCHAR(225) NOT NULL,
EOF
    
    end

    (eval(doc).properties || []).each do |property|
      field_name = property.name
      case property.type.to_s
        when 'String'
          field_type = "VARCHAR(255) DEFAULT NULL"
        when 'Date'
          field_type = "date DEFAULT NULL"
        when 'Integer'
          if field_name.include?("sort_value")
            field_type = "VARCHAR(255) DEFAULT NULL"
          else 
            field_type = "INT(11) DEFAULT NULL"
          end
        when 'Time'
          field_type = "datetime DEFAULT NULL"
        when 'TrueClass'
          field_type = "tinyint(1) NOT NULL  DEFAULT '0'"
        else
          field_type = "TEXT DEFAULT NULL" 
      end
      person_table += <<EOF
      `#{field_name}` #{field_type},
EOF

    end

    person_table += <<EOF
      PRIMARY KEY (`#{doc_primary_key}`)
    ) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1;
EOF
    
    if !File.exists?(@@file_path + "#{table_name}.sql")
      file = File.new("#{@@file_path}#{table_name}.sql", 'w')
    end

    #deleting all file contents
    File.open(@@file_path + "#{table_name}.sql", 'w') do |f|
      f.truncate(0)
    end

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts person_table
    end

    return true
end

def build_mysql_database
    @section = "Build MSQL"
    start_date = "1900-01-01 00:00:00".to_time
    #end_date = (Date.today - 1.day).to_date.strftime("%Y-%m-%d 23:59:59").to_time
    end_date = (Date.today).to_date.strftime("%Y-%m-%d 23:59:59").to_time

    (@couchdb_files || []).each do |doc, data|
      create_file(data[:doc_primary_key], doc, data[:table_name])
    end
end

def create_mysql_database(model_name ,table_name,records_per_page,page_number,table_primary_key)
  start_date = "1900-01-01 00:00:00".to_time
    #end_date = (Date.today - 1.day).to_date.strftime("%Y-%m-%d 23:59:59").to_time
    end_date = DateTime.now
    data = [] ; sql_insert_field_plus_data = {}
    set_model = eval(model_name)
    #table_name = params[:table_name]
    #records_per_page = params[:records_per_page].to_i
    #page_number = params[:page_number].to_i
    #table_primary_key = params[:table_primary_key]

    begin
      count = set_model.by_updated_at.startkey(start_date).endkey(end_date).page(page_number).per(records_per_page).each.count
    rescue
      count = set_model.all.page(page_number).per(records_per_page).each.count
    end

    if count > 0
      begin
        count_couchdb = set_model.by_updated_at.startkey(start_date).endkey(end_date).page(page_number).per(records_per_page).each
      rescue
        count_couchdb = set_model.all.page(page_number).per(records_per_page).each
      end

      sql_statement =<<EOF

EOF

      sql_statement += "INSERT INTO #{table_name} (#{table_primary_key}, "
    else
        return
    end

    (count_couchdb || []).each do |person|
      sql_insert_field_plus_data[person.id] = [] if sql_insert_field_plus_data[person.id].blank?
      (person.properties || []).each do |property|
        sql_insert_field_plus_data[person.id] << {
          name: "#{property.name}" , data: person.send(property.name),
          type: property.type.to_s
        }    
      end
    end 

    (sql_insert_field_plus_data || []).each do |id, statements|
      (statements || []).each do |statement|
        sql_statement += "#{statement[:name]}, "
      end
      break
    end
    sql_statement = ("#{sql_statement[0..-3]}) VALUES ")

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts sql_statement
    end



    sql_statement = ''
    (sql_insert_field_plus_data || []).each do |id, statements|
      sql_statement += "('#{id}', "

      (statements || []).each do |statement|
        if statement[:data].blank?
          if statement[:type] == 'TrueClass'
            sql_statement += "0, "
          else 
            sql_statement += "NULL, "
          end
        elsif statement[:type] == 'Integer' || statement[:type] == 'TrueClass'
          sql_statement += "'#{statement[:data]}',"
        elsif statement[:type] == 'Date'
          sql_statement += '"' + "#{statement[:data].to_date.strftime('%Y-%m-%d')}" + '",'
        elsif statement[:type] == 'Time'
          sql_statement += '"' + "#{statement[:data].to_time.strftime('%Y-%m-%d %H:%M:%S')}" + '",'
        else
          if statement[:data].to_s.match(/"/)
            sql_statement += "'" + "#{statement[:data]}" + "',"
          else
            sql_statement += '"' + "#{statement[:data]}" + '",'
          end
        end
      end
      sql_statement = sql_statement[0..-2] + '),'
    end
    sql_statement = sql_statement[0..-2] + ";"

    File.open(@@file_path + "#{table_name}.sql", 'a') do |f|
      f.puts sql_statement
    end

    return
end

def generate_files
 
  (@couchdb_files || []).each do |doc, data|
      count  = eval(doc).count
      puts count
      page = 1
      records_per_page = 100
      current_count = 0

      while current_count  < count
        create_mysql_database(doc , data[:table_name],records_per_page,page,data[:doc_primary_key])
        page = page + 1
        current_count = page * records_per_page
      end
  end
end

def mysql_connection
     YAML.load_file(File.join(Rails.root, "config", "database.yml"))[Rails.env]
end

def load_sql_files
    database =mysql_connection['database']
    user = mysql_connection['username']
    password = mysql_connection['password']
    host = mysql_connection['host']

    file_path =  Rails.root.to_s + '/db/MySQL_data/'

    @documents = Dir.foreach(file_path) do |file|
        if file.match(".sql")
            `nice mysql -u#{user} #{database} -p#{password} -h #{host} < #{file_path}#{file}`
        end
    end

    puts "MSQL Database Dump Loaded"
end

build_mysql_database
generate_files
load_sql_files

PersonIdentifier.can_assign_den = true

sql = "SET FOREIGN_KEY_CHECKS = 1;"
SimpleSQL.query_exec(sql)