module ApplicationHelper
  def configs
    YAML.load_file("#{Rails.root}/config/couchdb.yml")["#{Rails.env}"]
  end

  def site_type
    configs['site_type']
  end
end
