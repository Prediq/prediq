=begin
select * from db_setting  where `key` = 'config_encryption';

-- b9d6e2efb3c49c2cc612178c97b13f3a
=end

require 'rubygems'
require 'base64'
require 'mcrypt'

encoded_token = 'bc2Bf0uFc6tHmKSSsUjumxolHDBu+aOW3Dt2/9KAIYHg8Ck5gto61a5+Nvm1BQ1QZebfdIWQ+ieDIoFUYhViR+JxWbG1HpAvF80BHXHbomHhGaZi3JYxKKuR7597KK0ZEl0neclbiTKXGzrFxZ55aDHjIG23Z8wu1SE0gckun2PgFw=='
# encoded = '5mLlvP+9ahLl3jVQgslPQ6naFJKXUkVOmUOk7eWu2T27odoJ0naFZvEumP5YZ/qooxPK4hvXNqbqTCDYfjjLc1TrzjybczCQcJGJozrFMjkhvlEdRBG1KED6kPcCy/nJ0zdvEzgk2O1+bi76ZuzKNl1nODHH5LA61aYM/Us87+VJr37ApJPQ5nsVOJsl+Q=='

=begin
decrypted_token = '87873904be205b499fbab0ebca499ccbe8fd'
plaintext_token = '87873904be205b499fbab0ebca499ccbe8fd'
key = "b9d6e2efb3c49c2cc612178c97b13f3a"
salt = key

# base64_decode() equivalent
encrypted = Base64.encode64(decrypted_token)

# preparing Mcrypt library for Rijndael cipher, 256 bits, ECB mode
cipher = Mcrypt.new(:rijndael_256, :ecb, salt, nil, :zeros)

# padding required
encrypted = encrypted.ljust((encrypted.size / 32.0).ceil * 32, "\0")

# decrypt using Rijndael
decrypted = cipher.decrypt(encrypted).strip

Base64.decode64(decrypted)

# crypto = Mcrypt
# Mcrypt.new(:tripledes, :ecb, Digest::MD5.hexdigest(key)[0,24])
# plaintext  = Mcrypt.decrypt(Base64.decode64('some_encryped_base_64_encoded_string')).strip

crypto = Mcrypt.new(:rijndael_256, :ebc, key, nil, :zeros)

# encryption and decryption in one step
ciphertext = crypto.encrypt(plaintext_token)
plaintext  = crypto.decrypt(ciphertext)
=end

# http://stackoverflow.com/questions/21485437/encrypting-in-php-mcrypt-decrypting-in-ruby-opensslcipher

# https://github.com/kingpong/ruby-mcrypt

# http://stackoverflow.com/questions/23745059/decrypting-php-mcrypt-rijndael-256-in-ruby
# NOTE: The example as given was missing the '# encrypt using Rijndael' part, below
# Although this works, it does not result in the large
# encoded_token = 'bc2Bf0uFc6tHmKSSsUjumxolHDBu+aOW3Dt2/9KAIYHg8Ck5gto61a5+Nvm1BQ1QZebfdIWQ+ieDIoFUYhViR+JxWbG1HpAvF80BHXHbomHhGaZi3JYxKKuR7597KK0ZEl0neclbiTKXGzrFxZ55aDHjIG23Z8wu1SE0gckun2PgFw=='

plaintext_token = '87873904be205b499fbab0ebca499ccbe8fd'
key = "b9d6e2efb3c49c2cc612178c97b13f3a"
salt = key

# base64_decode() equivalent
encrypted = Base64.decode64(plaintext_token)

puts "*** #{encrypted}"

# preparing Mcrypt library for Rijndael cipher, 256 bits, ECB mode
# works: cipher = Mcrypt.new(:rijndael_256, :ecb, key, nil, :zeros)
cipher = Mcrypt.new(:rijndael_256, :ofb, key, '01234567890123456789012345678901', :zeros)
puts "*** cipher: #{cipher}"

# padding required
encrypted = encrypted.ljust((encrypted.size / 32.0).ceil * 32, "\0")
puts "*** encrypted: #{encrypted}"

# encrypt using Rijndael
encrypted = cipher.encrypt(encrypted)
puts "**** encrypted: #{encrypted}"

# decrypt using Rijndael
decrypted = cipher.decrypt(encrypted).strip

puts "*** decrypted: #{decrypted}"

puts "***** Base64.decode64(decrypted): #{Base64.encode64(decrypted)}"