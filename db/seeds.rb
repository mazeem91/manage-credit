# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts "Seeding..."

acc1 = Account.create(first_name: 'Matz', last_name: 'kai', email: 'acc@test.com', phone_number: '123123', status: :verified)
account_controler = Api::V1::AccountsController.new
account_controler.topup(acc1, 4000)

Account.create(first_name: 'Mai', last_name: 'Ann', email: 'acc2@test.com', phone_number: '456456', status: :verified)
Account.create(first_name: 'John', last_name: 'Doe', email: 'acc3@test.com', phone_number: '000111')


puts "Seeding done."
