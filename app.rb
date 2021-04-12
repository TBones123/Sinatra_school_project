#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'

def is_barber_exists? db, name
  db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers

  barbers.each do |barber|
    if !is_barber_exists? db, barber
      db.execute 'insert into Barbers (name) values (?)', [barber]
    end
  end


end


def get_db
  db = SQLite3::Database.new 'db/barbershop.db'
  db.results_as_hash = true
  return db
end

configure do
  db = get_db
  # @db = SQLite3::Database.new 'barbershop.db'
  db.execute 'CREATE TABLE IF NOT EXISTS
"Users"
(
"id" INTEGER PRIMARY KEY AUTOINCREMENT,
"username" TEXT,
"phone" TEXT,
"datestamp" TEXT,
"barber" TEXT,
"color" TEXT
)'

  db.execute 'CREATE TABLE IF NOT EXISTS
"Barbers"
(
"id" INTEGER PRIMARY KEY AUTOINCREMENT,
"name" TEXT
)'
  seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']

end

get '/' do
  erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>!!!!"
end
get '/about' do

  @error = 'somthing wrong'
  erb :about
end
get '/visit' do
  erb :visit
end

get '/contacts' do
  erb :contacts
end

get '/showusers' do
  db = get_db
  @resaults = db.execute 'select * from Users order by id desc'
  erb :showusers
end

post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @choice_form = params[:choice_form]
  @color = params[:color]

  hh = {
    :username => 'введите имя',
    :phone => 'введите тел',
    :datetime => 'введите дату'
  }
  @error = hh.select { |key, _| params[key] == "" }.values.join(", ")
  if @error != ''
    return erb :visit
  end

  db = get_db
  db.execute 'insert into
Users
(
username,
phone,
datestamp,
barber,
color
)
values(?,?,?,?,?)',[@username,@phone,@datetime,@choice_form,@color]




  # hh.each do |key, value|
  #   if params[key] == ''
  #     @error = hh[key]
  #     return erb :visit
  #   end
  # end

  save_log_visit
  @send = "thx for visit #{@username}, #{@phone}, #{@choice_form}, #{@color}, #{@datetime}"
  erb :visit

end
def save_db_visit

end


post '/contacts' do

  @emeil = params[:name_email]
  @text = params[:context_area]
  hh = {
    :name_email => 'введите email',
    :context_area => 'введите текст сообщения'
  }
  @error = hh.select { |key, _| params[key] == "" }.values.join(", ")
  if @error != ''
    return erb :contacts
  end
   erb :contacts
end

def save_log_contacts
  f = File.open './public/contacts.txt', 'a'
  f.write "===============\nemail #{@emeil}\ntext: #{@text}\n=============="
  f.close
end

def save_log_visit
  f = File.open './public/users.txt', 'a'
  f.write "name #{@username} phone: #{@phone} choice: #{@choice_form}\n"
  f.close
end

