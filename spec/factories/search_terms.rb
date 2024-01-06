# frozen_string_literal: true

FactoryBot.define do
  factory :search_term do
    term { Faker::Lorem.word }
    count { 1 }
    ip_address { Faker::Internet.ip_v4_address }
    created_at { Faker::Time.between(from: 30.seconds, to: 5.minutes) }
  end
end
