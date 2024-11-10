puts 'Event Manager Initialized!'

File.exist? 'event_attendees.csv'
contents = File.read('event_attendees.csv')
puts contents

lines = File.readlines('event_attendees.csv')
lines.each do |line|
  puts lines
end
