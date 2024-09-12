FactoryBot.define do
  factory :user do
    user_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { "0766257688" }
    role { 0 }
    password { "password" }
    encrypted_password {Devise::Encryptor.digest(User, password)}
    confirmed_at { Time.zone.now }
    confirmation_sent_at { Time.zone.now }
    confirmation_token { SecureRandom.urlsafe_base64 }
  end

  factory :admin_user, class: "User" do
    email { "admin@email.com" }
    user_name { "Admin" }
    password { "adminaccount" }
    role { 1 }
    phone { "0987654322" }
    confirmed_at { Time.zone.now }
  end
end
