
count = District.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	District.all.page(page).per(pagesize).each do |district|
		district.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

count = TraditionalAuthority.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	TraditionalAuthority.all.page(page).per(pagesize).each do |ta|
		ta.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

count = Village.count
pagesize = 200
pages = (count / pagesize) + 1
page = 1

while page <= pages
	Village.all.page(page).per(pagesize).each do |vl|
		vl.insert_update_into_mysql
	end

	puts page
	page = page + 1
end

puts "Done loading metadata"