require 'rubygems'
require 'bundler/setup'

require 'pusher'
require 'sinatra'

# Heroku will set PUSHER_URL.
unless ENV['PUSHER_URL']
  Pusher.app_id = ENV['PUSHER_APP_ID']
  Pusher.key    = ENV['PUSHER_KEY']
  Pusher.secret = ENV['PUSHER_SECRET']
end

post '/' do
  raw = request.env.select do |key,_|
    key[/\AHTTP_/]
  end.map do |key,value|
    "#{key.sub(/\AHTTP_/, '').gsub('_', '-').downcase.gsub(/\b([a-z])/) {$1.capitalize}}: #{value}"
  end

  raw += ['', request.body.read]

  Pusher['requests'].trigger('post', :raw => raw.join("\r\n"))
end

# If you want to see the keys used by Rack.
post '/rack' do
  raw = request.env.select do |key,_|
    key[/\AHTTP_/]
  end.map do |key,value|
    "#{key}: #{value}"
  end

  raw += ['', request.body.read]

  Pusher['requests'].trigger('post', :raw => raw.join("\r\n"))
end

get '/' do
  erb :index
end

# Some providers, like Mandrill, get upset if the bin doesn't respond to GET.
get '/rack' do
  204
end

run Sinatra::Application

__END__
@@layout
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Rackbin</title>
<script src="//js.pusher.com/2.0/pusher.min.js"></script>
<script>
var pusher = new Pusher('<%= Pusher.key %>');
var channel = pusher.subscribe('requests');
channel.bind('post', function (data) {
  document.write('<hr><pre>' + data.raw + '</pre>');
});
</script>
</head>
<body>
<%= yield %>
</body>
</html>

@@index
<p>Send a POST request to this URL to start!</p>
