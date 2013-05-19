# Rackbin: The simplest possible Rack postbin

[Requestb.in](http://requestb.in/) is great, except it limits requests to 10,240 bytes, you can't choose your URL path, and it can't handle non-ASCII, non-UTF8 POST requests. This postbin, or "requestbin", is easy to install and customize, has no limits, uses any URL path and accepts all encodings. Just open your bin's URL and wait for the requests!

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

* You can POST and listen for requests at any URL path. For example, `/foo` displays only POST requests to `/foo`, making it easy to isolate requests from different services. You must have the bin's page open in your browser before POST requests are sent.
* `/rack` is a special path that displays HTTP headers as environment variables (and displays only POST requests to `/rack`). Useful if you are testing webhooks to be consumed by Rack apps.
* Rackbin is less than 100 lines of code, all in [`config.ru`](https://github.com/opennorth/rackbin/blob/master/config.ru), making it easy to tailor to your needs.
* If you must send non-ASCII, non-UTF-8 POST requests, send your request to the appropriate, case-sensitive path below (otherwise, Rackbin will silently fail). Unlike other paths, you must refresh the bin's page after POST requests are sent. You may need to change your browser's encoding.

        ASCII-8BIT
        Big5
        Big5-HKSCS
        Big5-UAO
        CP50220
        CP50221
        CP51932
        CP850
        CP852
        CP855
        CP949
        CP950
        CP951
        EUC-JP
        EUC-KR
        EUC-TW
        Emacs-Mule
        GB12345
        GB18030
        GB1988
        GB2312
        GBK
        IBM437
        IBM737
        IBM775
        IBM852
        IBM855
        IBM857
        IBM860
        IBM861
        IBM862
        IBM863
        IBM864
        IBM865
        IBM866
        IBM869
        ISO-2022-JP
        ISO-2022-JP-2
        ISO-2022-JP-KDDI
        ISO-8859-1
        ISO-8859-10
        ISO-8859-11
        ISO-8859-13
        ISO-8859-14
        ISO-8859-15
        ISO-8859-16
        ISO-8859-2
        ISO-8859-3
        ISO-8859-4
        ISO-8859-5
        ISO-8859-6
        ISO-8859-7
        ISO-8859-8
        ISO-8859-9
        KOI8-R
        KOI8-U
        MacJapanese
        SJIS-DoCoMo
        SJIS-KDDI
        SJIS-SoftBank
        Shift_JIS
        TIS-620
        US-ASCII
        UTF-16
        UTF-16BE
        UTF-16LE
        UTF-32
        UTF-32BE
        UTF-32LE
        UTF-7
        UTF-8
        UTF8-DoCoMo
        UTF8-KDDI
        UTF8-MAC
        UTF8-SoftBank
        Windows-1250
        Windows-1251
        Windows-1252
        Windows-1253
        Windows-1254
        Windows-1255
        Windows-1256
        Windows-1257
        Windows-1258
        Windows-31J
        Windows-874
        eucJP-ms
        macCentEuro
        macCroatian
        macCyrillic
        macGreek
        macIceland
        macRoman
        macRomania
        macThai
        macTurkish
        macUkraine
        stateless-ISO-2022-JP
        stateless-ISO-2022-JP-KDDI

## Why?

* Some services change their output format depending on the URL. [Mailgun](http://documentation.mailgun.com/user_manual.html#mime-messages-parameters), for example, will only deliver raw MIME messages to URLs ending with `mime`. With Rackbin, you can easily route your requests to e.g. `/post_mime`.
* Other postbins don't handle non-ASCII, non-UTF8 POST requests gracefully (or at all).

In most cases, you are probably better served by [Requestb.in](http://requestb.in/).

## Caveats

* Rackbin uses [Pusher](http://pusher.com/), which sends messages in 10kB chunks. Sending a large POST (>1MB) is therefore not recommended. (Pusher is used to avoid database maintenance. Rackbin stores no data.)
* URL paths should contain only upper- and lowercase letters, numbers and the following punctuation `_ - = @ , . ;`. The `/` path separator is converted to `_`. All other characters are ignored. As such, `/foo!` displays the same POSTs as `/foo`.
* `/requests` is the default bin, therefore `/` displays the same POSTs as `/requests`.

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/rackbin](http://github.com/opennorth/rackbin), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2013 Open North Inc., released under the MIT license
