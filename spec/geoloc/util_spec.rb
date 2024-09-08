# frozen_string_literal: true

require 'json'
require 'open3'

RSpec.describe Geoloc::Util do
  it 'displays the latitude and longitude for city, state and zip using the --locations flag' do
    VCR.use_cassette('locations_flag') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '--locations', 'Madison, WI', '11208', 'Chicago, IL')
    
      expect(status.success?).to be true
      expect(stdout).to include('Location: Madison, Lat: 43.074761, Lon: -89.3837613')
      expect(stdout).to include('Location: New York, Lat: 40.6762, Lon: -73.8736')
      expect(stdout).to include('Location: Chicago, Lat: 41.8755616, Lon: -87.6244212')
      expect(stderr).to be_empty
    end
  end

  it 'displays the latitude and longitude for city, state and zip using the -l flag' do
    VCR.use_cassette('locations_shorthand_flag') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '-l', 'Madison, WI', '11208')
      
      expect(status.success?).to be true
      expect(stdout).to include('Location: Madison, Lat: 43.074761, Lon: -89.3837613')
      expect(stdout).to include('Location: New York, Lat: 40.6762, Lon: -73.8736')
      expect(stderr).to be_empty
    end
  end

  it 'displays an error if the city/state is not wrapped in quotes' do
    VCR.use_cassette('locations_error') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '--locations', 'Madison,', 'WI', '11208', 'Chicago, IL')

      expect(status.success?).to be true
      expect(stderr).to include("Error: Invalid location format for 'Madison, WI'. Please wrap city and state in quotes.")
      expect(stdout).to include('Location: New York, Lat: 40.6762, Lon: -73.8736')
      expect(stdout).to include('Location: Chicago, Lat: 41.8755616, Lon: -87.6244212')
    end
  end

  it 'displays an error message when there are no flags passed' do
    VCR.use_cassette("no_flags") do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', 'Madison, WI', '11208', 'Chicago, IL')
      
      expect(stderr).to include('Error: Please provide a location or zip code using the --locations or --zip flag.')
    end
  end

  it 'displays the latitude and longitude for a valid zip code with the shorthand -z flag' do
    VCR.use_cassette('zip_code_shorthand') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '-z', '33101')

      expect(status.success?).to be true
      expect(stdout).to include('Location: Miami, Lat: 25.7791, Lon: -80.1978')
      expect(stderr).to be_empty
    end
  end

  it 'displays the latitude and longitude for a valid zip code with the --zip flag' do
    VCR.use_cassette('zip_code_flag') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '--zip', '10003')

      expect(status.success?).to be true
      expect(stdout).to include('Location: New York, Lat: 40.7313, Lon: -73.9892')
      expect(stderr).to be_empty
    end
  end

  it 'displays the latitude and longitude for multiple valid zip codes' do
    VCR.use_cassette('multiple_zip_codes') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '--zip', '11221', '33101', '19019')

      expect(status.success?).to be true
      expect(stdout).to include('Location: New York, Lat: 40.6907, Lon: -73.9274')
      expect(stdout).to include('Location: Miami, Lat: 25.7791, Lon: -80.1978')
      expect(stdout).to include('Location: Philadelphia, Lat: 40.0018, Lon: -75.1179')
    end
  end

  it 'displays an error message when an invalid zip code is provided' do
    VCR.use_cassette('invalid_zip_code') do
      zip_code = '0000000000'
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '--zip', zip_code)

      expect(stderr).to include("Invalid zip code: #{zip_code}")
    end
  end

  it 'displays the help message with -h option' do
    VCR.use_cassette('help_flag') do
      stdout, stderr, status = Open3.capture3('./exe/geoloc-util', '-h')

      expect(status.success?).to be true
      expect(stdout).to include('Usage:')
      expect(stdout).to include('geoloc-util [options]')
      expect(stdout).to include('-l, --locations=<s+>') # Just checking the key part
      expect(stdout).to include('List of locations, city & state must be wrapped') # Check partial text
      expect(stdout).to include('-z, --zip=<s+>          List of zip codes')
      expect(stdout).to include('-h, --help              View available commands')
    end
  end
end
