# Rackbin: The simplest possible Rack postbin

[Requestb.in](http://requestb.in/) is great, except it limits requests to 10,240 bytes, and you can't choose your URL path. This postbin, or "requestbin", is easy to install, has no limits and uses any URL path. Just open your bin's URL and wait for the requests!

## Getting Started

* [Sign up for a Heroku account](https://id.heroku.com/signup)
* [Download the Heroku Toolbelt](https://toolbelt.heroku.com/)
* Deploy to Heroku

        git clone https://github.com/opennorth/rackbin.git
        cd rackbin
        heroku create
        heroku addons:add pusher:sandbox
        git push heroku master

* Open your bin's URL and wait for requests

        heroku open

* POST requests to your bin's URL

## Features

* You can POST and listen for requests at any URL path. For example, `/foo` displays only POSTs to `/foo`, making it easy to isolate requests from different services.
* `/rack` is a special route that displays HTTP headers as environment variables (and displays only POSTs to `/rack`). Useful if you are testing webhooks to be consumed by Rack apps.
* Rackbin is less than 100 lines of code, all in `config.ru`, making it easy to tailor to your needs.

## Why?

* Some services change their output format depending on the URL. [Mailgun](http://documentation.mailgun.com/user_manual.html#mime-messages-parameters), for example, will only deliver raw MIME messages to URLs ending with `mime`. With Rackbin, you can easily route your requests to e.g. `/post_mime`.

In most cases, you are probably better served by [Requestb.in](http://requestb.in/).

## Caveats

* RackBin uses [Pusher](http://pusher.com/), which sends messages in 10kB chunks. Sending a large POST (>1MB) is therefore not recommended. Pusher is used to avoid database maintenance. Rackbin stores no data.
* URL paths should contain only upper- and lowercase letters, numbers and the following punctuation: `_ - = @ , . ;` (due to Pusher's restrictions). The `/` path separator will be converted to `_`. All other characters will be ignored. As such, `/foo!` displays the same POSTs as `/foo`.
* `/requests` is the default bin, therefore `/` display the same POSTs as `/requests`.

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/rackbin](http://github.com/opennorth/rackbin), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2013 Open North Inc., released under the MIT license
