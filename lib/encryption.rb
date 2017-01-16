class String  

  @@key = Rails.application.secrets.secret_key_base

  def encrypt
    AESCrypt.encrypt(self, @@key) 
  end

  def decrypt
    AESCrypt.decrypt(self, @@key) 
  end

end
