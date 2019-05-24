t1 = Thread.new{
	a = Person.all.count
	puts a
}
t2 = Thread.new{
	s =PersonRecordStatus.all.count
	puts s
}
t3 = Thread.new{
	i =PersonIdentifier.all.count
	puts i
}
t4 = Thread.new{
	v =Village.all.count
	puts v
}
t5 = Thread.new{
	d =District.all.count
	puts d
}
t6 = Thread.new{
	t =TraditionalAuthority.all.count
	puts t
}
t7 = Thread.new{
	u =User.all.count
	puts u
}

t8 = Thread.new{
	b =Barcode.all.count
	puts b
}

t9 = Thread.new{
	b =HealthFacility.all.count
	puts b
}
t1.join
t2.join
t3.join
t4.join
t5.join
t6.join
t7.join
t8.join
t9.join