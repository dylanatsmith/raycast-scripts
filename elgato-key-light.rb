#!/usr/bin/env ruby


# Parameters

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Key Light
# @raycast.mode silent

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "Brightness", "optional": true }
# @raycast.argument2 { "type": "text", "placeholder": "Temperature", "optional": true }

# Documentation:
# @raycast.description Set Elgato Key Light brightness and temperature


# If accepting an argument:
arg1 = ARGV[0].to_i
arg2 = ARGV[1].to_i


# Configuration
# Tip: Change this IP address to the IP listed in the settings for your light
# behind the slider icon in the Elgato Key Light app.
HOST="192.168.8.151"
PORT="9123"


# Main program

# Temperature ranges from 143 to 344. This is a difference of 201.
# So arg can be 0–100 and then gets multipled and added to the lowest
# possible temp to make things easier for input.
def temperatureScaleToValue(scaleInput)
  return 143 + (scaleInput * 2)
end

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

  if (!arg1.nil? && !arg1.zero?)
    newBrightness = arg1
  else
    newBrightness = first_light["brightness"]
  end

  if (!arg2.nil? && !arg2.zero?)
    newTemperature = temperatureScaleToValue(arg2)
  else
    newTemperature = first_light["temperature"]
  end

  uri = URI("http://#{HOST}:#{PORT}/elgato/lights")
  req = Net::HTTP::Put.new(uri)
  req.body = {
    "numberOfLights": 1,
    "lights": [
      {
        "on": 1,
        "brightness": newBrightness,
        "temperature": newTemperature
      }
    ]
  }.to_json

  res = Net::HTTP.start(uri.hostname, uri.port) { |http|
    http.request(req)
  }

  if res.code == "200"
    puts "Key Light set to brightness #{newBrightness} and temperature #{ (newTemperature - 143) / 2 }"
  else
    puts "Key Light failed"
    exit(1)
  end
else
  puts "Failed loading lights"
  exit(1)
end
