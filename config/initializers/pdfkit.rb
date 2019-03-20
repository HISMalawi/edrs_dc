PDFKit.configure do |config|
  config.wkhtmltopdf = SETTINGS['wkhtmltopdf']
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true
  }
end