FactoryBot.define do
  factory :note do
    title { Faker::Book.title }
    content { Faker::Lorem.sentence(word_count: 20) }
    note_type { :review }
    association :user, strategy: :create
  end
end