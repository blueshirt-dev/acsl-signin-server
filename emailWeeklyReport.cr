require "sqlite3" 
require "email"

puts "Local: #{Time.local}, UTC: #{Time.utc}"
totalMinutes = 0
names = 0
emails = [] of String
lastWeek = Time.utc - 7.days
puts "#{lastWeek}"
DB.open "sqlite3://./data.db" do |db|
    db.query("select name, time from signin where time > ? order by time asc", lastWeek) do |rs|
        # puts "#{rs.column_name(0)} (#{rs.column_name(1)})"
        rs.each do
            name = rs.read(String)
            if(name != "Server Start")
                time = rs.read(String)
                time = Time.parse(time, "%Y-%m-%d %H:%M:%S.%L", Time::Location::UTC)
                endTime = Time.utc(time.year, time.month, time.day, 22)
                endTime = endTime + 7.hours
                span = endTime - time
                totalMinutes = totalMinutes + span.minutes + (60 * span.hours)
                # puts "Signin Time: #{time}, End time: #{endTime}"
                # puts "Name: #{name}, minutes: #{span.total_minutes.format(decimal_places: 0)}"
                puts "Hours: #{span.hours}, Minutes: #{span.minutes}"
            end
        end
    end
    db.query("select count (distinct name) from signin where time > ?", lastWeek) do |rs|
        # puts "#{rs.column_name(0)}"
        rs.each do
            # Subtract one to remove the server start info
            names = rs.read(Number) - 1
            puts "Unique names: #{names}"
        end
    end
    db.query("select distinct email from signin where email_acceptable = ?", 1) do |rs|
        rs.each do 
            emails.push(rs.read(String))
        end
    end
end

puts "Hours: #{(totalMinutes/60).format(decimal_places: 2)}"

# Create email message
from = "from@from.net"

email = EMail::Message.new
email.from    from
email.to      "to@to.com"
email.subject "Lab report for week of #{lastWeek.date}"
email.message <<-EOM
    Unique Names: #{names}
    Total Hours: #{(totalMinutes/60).format(decimal_places: 2)}
    Email List: #{emails}
    EOM

# Set SMTP client configuration
config = EMail::Client::Config.new("smtp.example.com", 25, helo_domain: "smtp.example.com")
# config.use_tls(EMail::Client::TLSMode::SMTPS)
config.use_tls(EMail::Client::TLSMode::STARTTLS)
config.use_auth(from, "from.netAppPassword")

# Create SMTP client object
client = EMail::Client.new(config)

client.start do
  # In this block, default receiver is client
  send(email)
end