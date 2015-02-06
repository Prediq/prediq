require 'openssl'

require 'base64'

encoded = 'bc2Bf0uFc6tHmKSSsUjumxolHDBu+aOW3Dt2/9KAIYHg8Ck5gto61a5+Nvm1BQ1QZebfdIWQ+ieDIoFUYhViR+JxWbG1HpAvF80BHXHbomHhGaZi3JYxKKuR7597KK0ZEl0neclbiTKXGzrFxZ55aDHjIG23Z8wu1SE0gckun2PgFw=='
iv = encoded[0..31]

# text = Base64.decode64(text)
key = "b9d6e2efb3c49c2cc612178c97b13f3a"
# iv = "1234567890123456"

cipher_type = "AES-256-CBC"

def decipher(encoded)

  encoded = Base64.decode64(encoded)



  cipher = OpenSSL::Cipher::Cipher.new("AES-256-CBC")

  key = "b9d6e2efb3c49c2cc612178c97b13f3a"

  cipher.decrypt(key)

  encoded_data = cipher.update(encoded)

  encoded_data cipher.final

  return encoded_data

end