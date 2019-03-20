cron_tab_entries = `crontab -l`

PATH=`echo $PATH`

unless cron_tab_entries.include?("PATH")
	path = "(crontab -l 2>/dev/null; echo 'PATH=#{PATH}') | crontab -"
	`#{path}`
end

app_root = Rails.root

entries_to_add = [		
					"*/2 * * * * bash -l -c 'cd #{app_root}/bin/sync && ./sync.sh'",
					"*/1 * * * * bash -l -c 'cd #{app_root} && bundle exec rails r bin/scripts/couch-mysql.rb'",
					"0 2 * * * bash -l -c 'cd #{app_root} && bundle exec rails  r bin/scripts/save_mysql.rb'",
					"0 0 * * * bash -l -c 'cd #{app_root} && bundle exec rails  r bin/scripts/compact.rb'",
					"0 1 * * * bash -l -c 'cd #{app_root} && bundle exec rails r bin/scripts/index_couchdb.rb'"
				]

entries_to_add.each do |entry|
	next if cron_tab_entries.include?(entry)
	new_entry = "(crontab -l 2>/dev/null; echo \"#{entry}\") | crontab -"

	`#{new_entry}`
end
#puts cron_tab_entries