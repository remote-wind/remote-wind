#Remote Wind

Remote wind is a service that collects live wind data, and makes it available in various ways.
It is a Rails based REST application.

This open-source project is available under a [GNU GPL v3 license](http://www.gnu.org/copyleft/gpl.html)

See the [project wiki](https://github.com/remote-wind/remote-wind/wiki) for more detailed information and the [documentation](http://www.rubydoc.info/github/remote-wind/remote-wind/).

### Requirements
- see Gemfile
- mailcatcher: http://mailcatcher.me/

## Installation
- clone the repo
- If you are using RVM, it should autodetect the ruby version and gemset when you cd into directory
- bundle install

## Documentation
Documentation is available at:

http://www.rubydoc.info/github/remote-wind/remote-wind/

The API Documentation is written with [YARD](http://yardoc.org/).
To run the documentation server locally:

```bash
yard server --reload
```

### Having problems with bundle install on OS-X?
The libv8 gem often has problems installing on OS-X due to the lack of openssl
headers. What seems to work is using the system version of v8. `bundle config build.libv8 -- --with-system-v8`.


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
Thoughtbot
