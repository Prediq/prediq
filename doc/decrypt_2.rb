require 'openssl'

# your data
raw  = 'the data to be encrypted goes here'
pwd  = 'secret'
salt = OpenSSL::Random.random_bytes(8)

# prepare cipher for encryption
e = OpenSSL::Cipher.new('AES-256-CBC')
e.encrypt
# next, generate a PKCS5-based string for your key + initialization vector
key_iv = OpenSSL::PKCS5.pbkdf2_hmac_sha1(pwd, salt, 2000, e.key_len+e.iv_len)
key = key_iv[0, e.key_len]
iv  = key_iv[e.key_len, e.iv_len]

# now set the key and iv for the encrypting cipher
e.key = key
e.iv  = iv

# encrypt the data!
encrypted = '' << e.update(raw) << e.final
p encrypted

# and now we prepare to decrypt
d = OpenSSL::Cipher.new('AES-256-CBC')
d.decrypt
# now set the key and iv for the decrypting cipher
# this assumes that the password, salt, and iv are known,
# so then you would be able to generate the key as per above
d.key = key
d.iv  = iv

# decrypt the data!
decrypted = '' << d.update(encrypted) << d.final
p decrypted