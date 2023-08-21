require "replicate"
Replicate.configure do |config|
  config.api_token = ENV["REPLICATE_API_KEY"]
end
