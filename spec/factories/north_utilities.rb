FactoryBot.define do
  factory :north_utility, class: 'NorthUtility', parent: :utility do
    type { 'NorthUtility' }
    name { 'North Utility' }
    external_api_key { Faker::Lorem.word }
    external_api_secret { Faker::Lorem.word }
    base_url do
      'https://private-bfc6a-widergytrainingnorthutilityapi.apiary-mock.com'
    end
    external_api_authentication_url do
      'token'
    end
    books_data_url do
      'libros'
    end
    short_note_limit { 50 }
    medium_note_limit { 100 }
  end
end
