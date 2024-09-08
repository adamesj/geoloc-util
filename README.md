# Geoloc::Util

A Ruby CLI written with the optimist gem that uses the Open Weather Geocoding API (https://openweathermap.org/api/geocoding-api) to retrieve the Latitude and Longitude of a location in the US based on city/state or zip code.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle install geoloc-util
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install geoloc-util
```

## Usage

Please note, the `./exe/geoloc-util [OPTION]` command must be run from the root of the project directory.

`./exe/geoloc-util -h` or `./exe/geoloc-util --help` to view a list of available commands.

The --locations flag accepts any number valid US city and state (must be wrapped in quotes) and zip codes like so:
`./exe/geoloc-util --locations "Madison, WI" "11208" "Chicago, IL" "12345"`

The --zip or -z flag accepts any number of valid US zip codes (quotes are optional).
`./exe/geoloc-util --zip "11208" "12345" "33021`

If no flags are passed then you should see an error:

```
./exe/geoloc-util "Madison, WI" 12345 "Chicago, IL" 10001
Error: Please provide a location or zip code using the --locations or --zip flag.
```

To run the tests:
`rspec ./spec/geoloc/util_spec.rb`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
