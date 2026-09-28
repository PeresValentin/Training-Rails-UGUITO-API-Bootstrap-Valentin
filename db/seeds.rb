# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Admin User
FactoryBot.create(:admin_user, email: 'admin@example.com', password: 'password',
                               password_confirmation: 'password')

# Utilities
north_utility = FactoryBot.create(:north_utility, code: 1)
south_utility = FactoryBot.create(:south_utility, code: 2)

# Users
FactoryBot.create_list(:user, 20, utility: north_utility,
                                  password: '12345678', password_confirmation: '12345678')
FactoryBot.create_list(:user, 20, utility: south_utility,
                                  password: '12345678', password_confirmation: '12345678')

south_user = FactoryBot.create(
  :user,
  utility: south_utility,
  email: 'test_south@widergy.com',
  password: '12345678',
  password_confirmation: '12345678'
)

north_user = FactoryBot.create(
  :user,
  utility: north_utility,
  email: 'test_north@widergy.com',
  password: '12345678',
  password_confirmation: '12345678'
)

User.all.find_each do |user|
  random_books_amount = [1, 2, 3].sample
  FactoryBot.create_list(
    :book,
    random_books_amount,
    user: user,
    utility: user.utility
  )
end

# Notes - North Utility
Note.create!(
  title: 'North short review',
  content: 'palabra ' * 40,
  note_type: :review,
  user: north_user
)

Note.create!(
  title: 'North medium critique',
  content: 'palabra ' * 80,
  note_type: :critique,
  user: north_user
)

Note.create!(
  title: 'North long critique',
  content: 'palabra ' * 110,
  note_type: :critique,
  user: north_user
)

# Notes - South Utility
Note.create!(
  title: 'South short review',
  content: 'palabra ' * 50,
  note_type: :review,
  user: south_user
)

Note.create!(
  title: 'South medium critique',
  content: 'palabra ' * 90,
  note_type: :critique,
  user: south_user
)

Note.create!(
  title: 'South long critique',
  content: 'palabra ' * 130,
  note_type: :critique,
  user: south_user
)
