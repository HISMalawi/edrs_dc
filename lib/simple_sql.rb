require "rails"
class SimpleSQL

  CONFIGS = YAML.load_file("#{Rails.root}/config/database.yml")[Rails.env]

  def self.query(options, selected, accept_blanks=false)
    join_ext = ""
    where_ext = ""

    options.keys.each do |group|
      #next if selected[group].blank? && selected[group] != 'On'
      fields = options[group]
      fields.each do |field|
        next if !accept_blanks && selected[field].blank?
        where_ext += (where_ext.length > 0 ? " AND " : "")  + [field, " '#{selected[field]}' "].join(" = ")
      end
    end

    query = "SELECT person_id FROM people #{join_ext} WHERE #{where_ext}"

    puts query

    self.exec(query)
  end

  def self.exec(query)
    ids = (((`mysql -u #{CONFIGS['username']} -p#{CONFIGS['password']} #{CONFIGS['database']} -e "#{query}"`).split(/\n/) rescue []) - ['person_id']) rescue []
    people = []
    ids.each do |id|
      person = Record.find(id)
      if SETTINGS['site_type'] == "remote"
              next if (UserModel.current_user.district_code != person.district_code ) && (user.role !="System Administrator") && (user.site_code != "HQ")
          end
      people << person
    end

    people
  end

  def self.query_exec(query)
    insert = `mysql -u #{CONFIGS['username']} -p#{CONFIGS['password']} #{CONFIGS['database']} -e "#{query}"`
    return insert
  end

  def self.load_dump(file)
    load = `mysql -u #{CONFIGS['username']} -p#{CONFIGS['password']} #{CONFIGS['database']} < #{file}`
  end

end
