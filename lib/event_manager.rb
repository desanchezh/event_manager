# File.exist? 'event_attendees.csv'
# contents = File.read('event_attendees.csv')
# puts contents

# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#  puts lines
# end

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_number(phone_number)
  clean = phone_number.delete('^0-9')
  if clean.size == 10
    clean
  elsif clean.size == 11 && clean[0] == 1
    clean[-10]
  else
    '0000000000'
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def most_frequent_hour(regdate)
  p regdate.hour
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

reg_hours = []
reg_day = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  # should be seperate function
  regdate = (row[:regdate])
  time = regdate.split('').last(5).join
  reg_hours << DateTime.strptime(time, '%H:%M').hour
  begin
    date = regdate.split('').first(5).join
    date = Date.parse(date)
  rescue StandardError
    date = Date.parse('01/01/2008')
    date
  end
  reg_day << date.strftime('%a')
  p reg_day.tally
  p reg_hours.tally
  # should be seperate function^
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end
