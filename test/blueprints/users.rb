Sham.username {|i| Faker::Name.first_name.downcase + i.to_s}
Sham.email { Faker::Internet.email }

User.blueprint do
  username
  email
  password { 'secret' }
  password_confirmation { password }
end
