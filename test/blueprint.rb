

Sham.login {|i| Faker::Name.first_name.downcase + i.to_s}

User.blueprint do
  login
  password { 'secret' }
  password_confirmation    { password }
  
  #this is all needed so we can log in for functional tests
  password_salt {Authlogic::Random.hex_token }
  crypted_password { Authlogic::CryptoProviders::Sha512.encrypt(password + password_salt) }
  persistence_token { Authlogic::Random.hex_token }
  single_access_token { Authlogic::Random.friendly_token }
  perishable_token { Authlogic::Random.friendly_token }
end