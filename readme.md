#Remote Wind

Remote wind is a service that collects live wind data, and makes it available in various ways.
It is a Rails based REST application.

This open-source project is available under a [GNU GPL v3 license](http://www.gnu.org/copyleft/gpl.html)

See the [project wiki](https://github.com/remote-wind/remote-wind/wiki) for more detailed information.

### Requirements
```
RVM > 1.2
Ruby >= 2.0.0
Postgres > 9.3
```

## Installation
- set up RVM to use ruby 2.0.0 and create a gemset named remote-wind
- clone the repo
- bundle install
- install mailcatcher: http://mailcatcher.me/

### Set up enviromental vars
You may need set some enviromental vars to get the app running on your system.
```
cp .env.dist .env
```
Edit `.env` in your favorite text editor. DO NOT CHECK IT IN!
See see https://github.com/bkeepers/dotenv for details

## Mailcatcher
This app uses the mailcatcher smtp server for the dev environment
see http://mailcatcher.me/ for instructions

## Continuus testing with Guard and Zeus
```
zeus start
bundle exec guard (in a new tab)
```

## RailsPanel

This application supports debugging in Google chrome via [the RailsPanel extension](https://chrome.google.com/webstore/detail/railspanel/gjpfobpafnhjhbajcjgccbbdofdckggg)

## Thanks to
Norman Clarke
Benedikt Deicke


