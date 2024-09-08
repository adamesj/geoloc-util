# frozen_string_literal: true

require 'dotenv/load'
require 'json'
require 'uri'
require 'net/http'
require_relative 'util/version'
require 'pry'
require 'pry-nav'
require 'ostruct'

module Geoloc
  module Util
    class Error < StandardError; end

    def self.get(options = {})
      results = []
      invalid_locations = []
      errors = []

      if options[:locations].empty? && options[:zip].empty?
        ARGV.each do |arg|
          if arg.match?(/^\d{5}$/)
            results << process(:zip, arg)
          elsif arg.match(/^[^,]+,\s*\w{2}$/)
            results << process(:location, arg)
          else
            invalid_locations << arg
          end
        end
      else
        options[:locations]&.each do |location|
          if location.match?(/^\d{5}$/)
            results << process(:zip, location)
          elsif location.match(/^[^,]+,\s*\w{2}$/)
            results << process(:location, location)
          else
            invalid_locations << location
          end
        end

        options[:zip]&.each do |zip|
          results << process(:zip, zip)
        end
      end      
      
      unless invalid_locations.empty?
        invalid_locations.each_slice(2) do |city| 
          STDERR.puts "Error: Invalid location format for '#{city.join(" ")}'. Please wrap city and state in quotes."
        end
      end

    results.compact
  end

    private

    def self.valid_location?(location)
      location.match?(/^[^,]+,\s*[A-Z]{2}$/)
    end

    def self.process(type, query)
      url = build_url(type, query)
      result = handle_request(url)
      format_result(result)
    end

    def self.build_url(type, query)
      base_url = 'http://api.openweathermap.org/geo/1.0'
      encoded_query = URI.encode_www_form_component(query)

      case type
      when :zip
        "#{base_url}/zip?zip=#{encoded_query},US&appid=#{ENV['GEOLOCATOR_API_KEY']}"
      when :location
        "#{base_url}/direct?q=#{encoded_query},US&limit=1&appid=#{ENV['GEOLOCATOR_API_KEY']}"
      end
    end

    def self.handle_request(url)
      uri = URI(url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue => e
      puts "Error: #{e.message}"
    end

    def self.format_result(result)
      if result.is_a?(Array) && result.any?
        result = result.first
        "Location: #{result['name']}, Lat: #{result['lat']}, Lon: #{result['lon']}"
      elsif result.is_a?(Hash) && result['name'] && result['lat'] && result['lon']
        "Location: #{result['name']}, Lat: #{result['lat']}, Lon: #{result['lon']}"
      else
        "No valid result found."
      end
    end
  end
end
