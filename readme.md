RW2, Remote Wind - improved.
============================

This a rewrite from scratch of Karl-Petter Åkessons remote-wind. I rewrote it becuase of the difficulties of writing tests
after vs TDD.


Requirements
------------
``
RVM > 1.2
Ruby 2.0
GIT
Postgres >9.3
``

Installation
============
set up RVM to use ruby 2.0 and create a gemset named rw2
clone the repo

Enviromental vars
------------
The app uses enviromental vars in to avoid checking in passwords and local enviroment config.
Add the following to your ~/.profile (os-x) or  ~/.bash_profile (linux)
`
export REMOTE_WIND_EMAIL="your@email.com"
export REMOTE_WIND_PASSWORD="password"
export REMOTE_WIND_GEONAMES="username"
``
REMOTE_WIND_GEONAMES is a [geonames.org](http://www.geonames.org) username.
If you use an IDE on OS-x such as rubymine, you should add the following to /etc/launchd.conf
``
set_env REMOTE_WIND_EMAIL your@emai.com
set_env REMOTE_WIND_PASSWORD password
set_env REMOTE_WIND_GEONAMES username
``
Note that the variables should not be quoted!
``
source /etc/launchd.conf
``




