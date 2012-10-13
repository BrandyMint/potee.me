# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Project.create :title => 'Design for google.com',
  :started_at => Date.parse('2012-09-01'),
  :finish_at => Date.parse('2012-12-01'),
  :color_index => 1


Project.create :title => 'Make wife happy',
  :started_at => Date.parse('2012-09-15'),
  :finish_at => Date.parse('2012-11-04'),
  :color_index => 2

Project.create :title => 'Lear SCALA',
  :started_at => Date.parse('2012-09-25'),
  :finish_at => Date.parse('2013-01-09'),
  :color_index => 3
