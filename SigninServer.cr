require "kemal"
require "sqlite3"

def dbSetup
  puts "DBSetup"
  
  DB.open "sqlite3://./data.db" do |db|
    begin
      db.exec "create table if not exists signin (
        signin_skey integer primary key asc autoincrement,
        name,
        email,
        email_acceptable, 
        time
        )"
    end

    insertSignin(db, "Server Start", "", false, Time.utc)
  end
end

def insertSignin(db : DB::Database, name : String, email : String, emailAcceptable : Bool, time)
  # puts "name: #{name}"
  # puts "email: #{email}"
  puts "time: #{time}"
  # puts "send emails: #{emailAcceptable}"
  db.exec "insert into signin (name, email, email_acceptable, time) values (?, ?, ?, ?)", name, email, emailAcceptable, time
end

DB.open "sqlite3://./data.db" do |db|
  # Matches GET "http://host:port/"
  get "/" do
    render "public/index.html"
  end

  post "/" do |env|
    name = env.params.body["name"].as(String)
    email = env.params.body["email"].as(String)
    begin
      if(env.params.body["send"].as(String))
        emailAcceptable = true
      end
    rescue 
      emailAcceptable = false
    end
    insertSignin(db, name, email, emailAcceptable, Time.utc)
    render "public/success.html"
  end

  dbSetup

  Kemal.run
end