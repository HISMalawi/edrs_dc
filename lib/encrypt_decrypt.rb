require 'openssl'
require 'base64'

class EncryptDecrypt

  def self.encrypt(value)

    return value if !File.exists?("#{Rails.root}/config/public.pem")

    public_key_file = "#{Rails.root}/config/public.pem"

    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))

    encrypted_string = Base64.encode64(public_key.public_encrypt(value)) rescue nil

    return encrypted_string

  end

  def self.decrypt(value)

    return value if !File.exists?("#{Rails.root}/config/private.pem")

    private_key_file = "#{Rails.root}/config/private.pem"

    password = CONFIG["crtkey"] rescue nil

    return value if password.nil?

    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file), password)

    string = private_key.private_decrypt(Base64.decode64(value)) rescue nil

    return value if string.nil?

    return string

  end

end
