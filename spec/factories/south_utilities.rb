FactoryBot.define do
  factory :south_utility, class: 'SouthUtility', parent: :utility do
    type { 'SouthUtility' }
    name { 'South Utility' }
    external_api_key { Faker::Lorem.word }
    external_api_secret { Faker::Lorem.word }
    base_url do
      'https://private-1971b-widergytrainingsouthutilityapi.apiary-mock.com'
    end
    external_api_authentication_url do
      'Token'
    end
    books_data_url do
      'Libros'
    end
    short_note_limit { 60 }
    medium_note_limit { 120 }
  end
end
