# Rackbin: The simplest possible Rack postbin

[Requestb.in](http://requestb.in/) is great, except it limits requests to 10,240 bytes, and you can't choose your URL path. This postbin, or "requestbin", is easy to install and customize, has no limits and uses any URL path. Just open your bin's URL and wait for the requests!

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

* You can POST and listen for requests at any URL path. For example, `/foo` displays only POST requests to `/foo`, making it easy to isolate requests from different services.
* `/rack` is a special path that displays HTTP headers as environment variables (and displays only POST requests to `/rack`). Useful if you are testing webhooks to be consumed by Rack apps.
* Rackbin is less than 100 lines of code, all in [`config.ru`](https://github.com/opennorth/rackbin/blob/master/config.ru), making it easy to tailor to your needs.
* If you must send non-ASCII, non-UTF-8 POST requests, send your request to the appropriate, case-sensitive path below (otherwise, RackBin will silently fail):

    ASCII-8BIT
    UTF-8
    US-ASCII
    Big5
    Big5-HKSCS
    Big5-UAO
    CP949
    Emacs-Mule
    EUC-JP
    EUC-KR
    EUC-TW
    GB18030
    GBK
    ISO-8859-1
    ISO-8859-2
    ISO-8859-3
    ISO-8859-4
    ISO-8859-5
    ISO-8859-6
    ISO-8859-7
    ISO-8859-8
    ISO-8859-9
    ISO-8859-10
    ISO-8859-11
    ISO-8859-13
    ISO-8859-14
    ISO-8859-15
    ISO-8859-16
    KOI8-R
    KOI8-U
    Shift_JIS
    UTF-16BE
    UTF-16LE
    UTF-32BE
    UTF-32LE
    Windows-1251
    IBM437
    IBM737
    IBM775
    CP850
    IBM852
    CP852
    IBM855
    CP855
    IBM857
    IBM860
    IBM861
    IBM862
    IBM863
    IBM864
    IBM865
    IBM866
    IBM869
    Windows-1258
    GB1988
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
    CP950
    CP951
    stateless-ISO-2022-JP
    eucJP-ms
    CP51932
    GB2312
    GB12345
    ISO-2022-JP
    ISO-2022-JP-2
    CP50220
    CP50221
    Windows-1252
    Windows-1250
    Windows-1256
    Windows-1253
    Windows-1255
    Windows-1254
    TIS-620
    Windows-874
    Windows-1257
    Windows-31J
    MacJapanese
    UTF-7
    UTF8-MAC
    UTF-16
    UTF-32
    UTF8-DoCoMo
    SJIS-DoCoMo
    UTF8-KDDI
    SJIS-KDDI
    ISO-2022-JP-KDDI
    stateless-ISO-2022-JP-KDDI
    UTF8-SoftBank
    SJIS-SoftBank

## Why?

* Some services change their output format depending on the URL. [Mailgun](http://documentation.mailgun.com/user_manual.html#mime-messages-parameters), for example, will only deliver raw MIME messages to URLs ending with `mime`. With Rackbin, you can easily route your requests to e.g. `/post_mime`.

In most cases, you are probably better served by [Requestb.in](http://requestb.in/).

## Caveats

* RackBin uses [Pusher](http://pusher.com/), which sends messages in 10kB chunks. Sending a large POST (>1MB) is therefore not recommended. (Pusher is used to avoid database maintenance. Rackbin stores no data.)
* URL paths should contain only upper- and lowercase letters, numbers and the following punctuation `_ - = @ , . ;`. The `/` path separator is converted to `_`. All other characters are ignored. As such, `/foo!` displays the same POSTs as `/foo`.
* `/requests` is the default bin, therefore `/` displays the same POSTs as `/requests`.

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/rackbin](http://github.com/opennorth/rackbin), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2013 Open North Inc., released under the MIT license
