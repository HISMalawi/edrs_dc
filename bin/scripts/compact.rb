@settings = CONFIG
COMPACT_URL=" curl -H \"Content-Type: application/json\" -XPOST  #{CONFIG['protocol']}://#{CONFIG['username']}:#{CONFIG['password']}@#{CONFIG['host']}:#{CONFIG['port']}/#{CONFIG['prefix']}_#{CONFIG['suffix']}/_compact"
puts COMPACT_URL
`#{COMPACT_URL}`