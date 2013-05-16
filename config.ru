require 'rubygems'
require 'bundler/setup'

require 'pusher'
require 'sinatra'

# Heroku will set PUSHER_URL.
unless ENV['PUSHER_URL']
  Pusher.app_id = ENV['PUSHER_APP_ID']
  Pusher.key = ENV['PUSHER_KEY']
  Pusher.secret = ENV['PUSHER_SECRET']
end

post '/' do
  raw = request.env.select do |key,_|
    key[/\AHTTP_/]
  end.map do |key,value|
    "#{key.sub(/\AHTTP_/, '').gsub('_', '-').downcase.gsub(/\b([a-z])/) {$1.capitalize}}: #{value}"
  end
  raw << ''
  raw << request.body.read

  Pusher['requests'].trigger('post', {raw: raw.join("\r\n")})
end

get '/' do
  erb :index
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
Pusher.log = function (message) {
  if (window.console && window.console.log) {
    window.console.log(message);
  }
};

WEB_SOCKET_DEBUG = true;

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
<p>Waiting for requests...</p>
