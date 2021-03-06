require 'rubygems'
require 'bundler/setup'

require 'cgi'

require 'dalli'
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
  def channel
    @channel ||= begin
      path = params[:splat].join
      if path.empty?
        'requests' # default
      else
        path.gsub('/', '_').gsub(/[^A-Za-z0-9,.;=@_-]/, '')
      end
    end
  end

  # @return [Boolean] whether the request is expected to be non-UTF8
  def encoded?
    Encoding.list.map(&:name).include?(channel)
  end

  # @return [String] the expected encoding
  def charset
    if encoded?
      channel
    else
      'UTF-8'
    end
  end

  # @return [Dalli::Client] a Memcache client
  def client
    @client ||= Dalli::Client.new(ENV['MEMCACHIER_SERVERS'], {
      :username => ENV['MEMCACHIER_USERNAME'],
      :password => ENV['MEMCACHIER_PASSWORD'],
    })
  end

  # @return [Array<Hash>] a list of POST requests
  def requests
    client.get(channel) || []
  end

  # @return [Hash] the request's HTTP headers
  def http_headers
    request.env.select do |key,_|
      key[/\A(?:HTTP_|CONTENT_)/]
    end
  end

  # @params [Array<String>] headers the request's HTTP headers
  def push(headers)
    # Rack calls `#set_encoding` with `BINARY` on `env['rack.input']`, which
    # is what `request.body` reads. `request.body.read` will be `ASCII-8BIT`,
    # an alias for `BINARY`. If we concatenate `body` with `headers`, it may/
    # will become `US-ASCII`.
    body = request.body.read

    if encoded?
      client.set(channel, requests.push({
        'headers' => headers.join("\r\n"),
        'body' => body.force_encoding(channel),
      }), 172_800) # 2 days
    else
      # Pusher has a maximum message length of 10kB (PubNub is 1800 bytes).
      # @see https://pusher.tenderapp.com/kb/publishingtriggering-events/what-is-the-message-size-limit-when-publishing-a-message
      # @see https://help.pubnub.com/entries/21100116-How-Many-Characters-Fit-into-One-Message-
      message = (headers + ['', body]).join("\r\n")
      message.chars.each_slice(10_000).each_with_index do |chars,index|
        Pusher[channel].trigger(index.zero? ? 'begin' : 'continue', :content => chars.join)
      end
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

get '/*/download' do
  if encoded?
    cache_control :no_cache, :max_age => 0
    attachment "#{channel}.txt"
    content_type "text/plain; charset=#{charset}"
    erb :download, :layout => false
  else
    404
  end
end

get '/*' do
  if encoded?
    erb :dalli
  else
    erb :pusher
  end
end

run Sinatra::Application

__END__
@@layout
<!DOCTYPE html>
<html>
<head>
<meta charset="<%= charset.downcase %>">
<title>Rackbin</title>
</head>
<body>
<%= yield %>
</body>
</html>

@@pusher
<script src="//js.pusher.com/2.0/pusher.min.js"></script>
<script>
var pusher = new Pusher('<%= Pusher.key %>');
var channel = pusher.subscribe('<%= channel %>');
function escape(string) {
  return string.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, "&#039;");
}
channel.bind('begin', function (data) {
  document.write('<hr><pre>' + escape(data.content) + '</pre>');
});
channel.bind('continue', function (data) {
  var tags = document.getElementsByTagName('pre');
  tags[tags.length - 1].innerHTML += escape(data.content);
});
</script>
<p>Send a POST request to this URL for your inspection.</p>

@@dalli
<% if requests.empty? %>
<p>Send a POST request to this URL then refresh this page.</p>
<% else %>
<p><a href="/<%= channel %>/download">Download all requests</a></p>
<% end %>
<% requests.each do |request| %>
<hr>
<pre>
<%= CGI.escapeHTML(request['headers']) %>


<%= CGI.escapeHTML(request['body']) %>
</pre>
<% end %>

@@download
<% requests.each do |request| %>
--------------------------------------------------------------------------------

<%= CGI.escapeHTML(request['headers']) %>


<%= CGI.escapeHTML(request['body']) %>
<% end %>
