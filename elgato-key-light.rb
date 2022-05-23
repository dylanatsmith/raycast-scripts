#!/usr/bin/env ruby


# Parameters

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Daytime
# @raycast.mode silent

# Documentation:
# @raycast.description Set Key Light to Daytime preset


# Configuration

HOST="192.168.8.141"
PORT="9123"


# Main program

require "json"
require "net/http"
require "uri"

uri = URI("http://#{HOST}:#{PORT}/elgato/lights")
req = Net::HTTP::Get.new(uri)

res = Net::HTTP.start(uri.hostname, uri.port) { |http|
  http.request(req)
}

if res.code == "200"
  result = JSON.parse(res.body)

  first_light = result["lights"].first()
  if first_light.nil?
    puts "Failed parsing first light"
    exit(1)
  end

  uri = URI("http://#{HOST}:#{PORT}/elgato/lights")
  req = Net::HTTP::Put.new(uri)
  req.body = {
    "numberOfLights": 1,
    "lights": [
      {
        "on": 1,
        # Brightness 0–100
        # Temperature 143–344
        "brightness": 20,
        "temperature": 25
      }
    ]
  }.to_json

  res = Net::HTTP.start(uri.hostname, uri.port) { |http|
    http.request(req)
  }

  if res.code == "200"
    puts "Key Light set to Daytime mode"
  else
    puts "Key Light failed to set Daytime mode"
    exit(1)
  end
else
  puts "Failed loading lights"
  exit(1)
end
