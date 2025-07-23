# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create test users for friendship functionality
unless User.exists?(email: 'john.doe@example.com')
  User.create!(
    first_name: 'John',
    last_name: 'Doe',
    email: 'john.doe@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
end

unless User.exists?(email: 'jane.smith@example.com')
  User.create!(
    first_name: 'Jane',
    last_name: 'Smith',
    email: 'jane.smith@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
end

unless User.exists?(email: 'mike.johnson@example.com')
  User.create!(
    first_name: 'Mike',
    last_name: 'Johnson',
    email: 'mike.johnson@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
end

unless User.exists?(email: 'sarah.wilson@example.com')
  User.create!(
    first_name: 'Sarah',
    last_name: 'Wilson',
    email: 'sarah.wilson@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
end

puts "Created #{User.count} test users"
