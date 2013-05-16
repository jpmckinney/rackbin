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

helpers do
  # @see http://pusher.com/docs/client_api_guide/client_channels#naming-channels
  def set_channel
    path = params[:splat].join
    @channel = if path.empty?
      'requests'
    else
      path.gsub('/', '_').gsub(/[^A-Za-z0-9,.;=@_-]/, '')
    end
  end

  def http_headers
    request.env.select do |key,_|
      key[/\AHTTP_/]
    end
  end

  def push(content)
    p request.body.read
    Pusher[@channel].trigger('post', :content => (content + ['', request.body.read]).join("\r\n"))
  end
end

post '/rack' do
  @channel = 'rack'
  content = http_headers.map do |key,value|
    "#{key}: #{value}"
  end
  push(content)
end

post '/*' do
  set_channel
  content = http_headers.map do |key,value|
    "#{key.sub(/\AHTTP_/, '').gsub('_', '-').downcase.gsub(/\b([a-z])/) {$1.capitalize}}: #{value}"
  end
  push(content)
end

get '/robots.txt' do
  "User-agent: *\nDisallow: /"
end

get '/favicon.ico' do
  204
end

get '/*' do
  set_channel
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
var pusher = new Pusher('<%= Pusher.key %>');
var channel = pusher.subscribe('<%= @channel %>');
channel.bind('post', function (data) {
  document.write('<hr><pre>' + data.content + '</pre>');
});
</script>
</head>
<body>
<%= yield %>
</body>
</html>

@@index
<p>Send a POST request to this URL to start!</p>
