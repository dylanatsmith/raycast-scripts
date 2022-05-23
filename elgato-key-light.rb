#!/usr/bin/env ruby


# Parameters

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Key Light
# @raycast.mode silent

# Optional parameters:
# @raycast.argument1 { "type": "text", "placeholder": "Brightness" }
# @raycast.argument2 { "type": "text", "placeholder": "Temperature" }

# Documentation:
# @raycast.description Set Elgato Key Light brightness and temperature



# Temperature ranges from 143 to 344. This is a difference of 201.
# So arg can be 0–10 and then gets multipled and added to the lowest
# possible temp to make things easier for input.
def temperatureScaleToValue(scaleInput)
  return 143 + (scaleInput * 20)
end

# If accepting an argument:
newBrightness = ARGV[0].to_i * 10
newTemperature = temperatureScaleToValue(ARGV[1].to_i)


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
        "brightness": newBrightness,
        "temperature": newTemperature
      }
    ]
  }.to_json

  res = Net::HTTP.start(uri.hostname, uri.port) { |http|
    http.request(req)
  }

  if res.code == "200"
    puts "Key Light set to brightness #{newBrightness} and temperature #{newTemperature}"
  else
    puts "Key Light failed"
    exit(1)
  end
else
  puts "Failed loading lights"
  exit(1)
end
