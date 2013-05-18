require 'rubygems'
require 'bundler/setup'

require 'pusher'
require 'sinatra'

# Heroku will set PUSHER_URL and PUSHER_SOCKET_URL. If you are running Rackbin
# in development, set the environment variables below before running `rackup`.
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
      'requests' # default
    else
      path.gsub('/', '_').gsub(/[^A-Za-z0-9,.;=@_-]/, '')
    end
  end

  def http_headers
    request.env.select do |key,_|
      key[/\A(?:HTTP_|CONTENT_)/]
    end
  end

  # Pusher has a maximum message length of 10kB (PubNub is 1800 bytes).
  # @see http://www.pubnub.com/tutorial/developer-intro-tutorial
  # @see https://pusher.tenderapp.com/kb/publishingtriggering-events/what-is-the-message-size-limit-when-publishing-a-message
  def push(headers)
    body = request.body.read
    message = (headers + ['', body]).join("\r\n")

    path = params[:splat].join
    if Encoding.list.map(&:name).include?(path)
      message = message.force_encoding(path)
    end

    message.chars.each_slice(10_000).each_with_index do |chars,index|
      Pusher[@channel].trigger(index.zero? ? 'begin' : 'continue', :content => chars.join)
    end
  end
end

post '/rack' do
  @channel = 'rack'
  headers = http_headers.map do |key,value|
    "#{key}: #{value}"
  end
  push(headers)
end

post '/*' do
  set_channel
  headers = http_headers.map do |key,value|
    "#{key.sub(/\AHTTP_/, '').gsub('_', '-').downcase.gsub(/\b([a-z])/) {$1.capitalize}}: #{value}"
  end
  push(headers)
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
channel.bind('begin', function (data) {
  document.write('<hr><pre>' + data.content.replace(/&/g, '&amp;') + '</pre>');
});
channel.bind('continue', function (data) {
  var tags = document.getElementsByTagName('pre');
  tags[tags.length - 1].innerHTML += data.content.replace(/&/g, '&amp;');
});
</script>
</head>
<body>
<%= yield %>
</body>
</html>

@@index
<p>Send a POST request to this URL to start!</p>
