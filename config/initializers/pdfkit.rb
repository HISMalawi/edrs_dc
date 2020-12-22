PDFKit.configure do |config|
  config.wkhtmltopdf = SETTINGS['wkhtmltopdf']
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true
  }
  # Use only if your external hostname is unavailable on the server.
  # config.root_url = "http://localhost"
  config.verbose = false
end