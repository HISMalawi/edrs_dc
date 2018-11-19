@settings = CONFIG
COMPACT_URL=" curl -H \"Content-Type: application/json\" -XPOST -d #{CONFIG['protocol']}://#{CONFIG['username']}:#{CONFIG['password']}@#{CONFIG['host']}:#{CONFIG['port']}/#{CONFIG['prefix']}#{CONFIG['suffix']}/_compact"
puts COMPACT_URL
`#{COMPACT_URL}`