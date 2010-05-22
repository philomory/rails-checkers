Sham.login {|i| Faker::Name.first_name.downcase + i.to_s}
Sham.name { Faker::Name.name }

User.blueprint do
  login
  name
end
