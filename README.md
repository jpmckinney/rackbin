# Rackbin: The simplest possible Rack postbin

[Requestb.in](http://requestb.in/) is great, except it limits requests to 10,240 bytes. This postbin, or "requestbin", is easy to install and has no limits. Just open your bin's URL and wait for the requests!

## Getting Started

* [Sign up for a Heroku account](https://id.heroku.com/signup)
* [Download the Heroku Toolbelt](https://toolbelt.heroku.com/)
* Deploy your bin

        git clone https://github.com/opennorth/rackbin.git
        cd rackbin
        heroku create
        heroku addons:add pusher:sandbox
        git push heroku master

* Open your bin's URL and wait for requests

        heroku open

* POST requests to your bin's URL

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/rackbin](http://github.com/opennorth/rackbin), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2013 Open North Inc., released under the MIT license
