Cloudinary.config do |config|
  config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME'] || 'connecting-hearts-dev'
  config.api_key    = ENV['CLOUDINARY_API_KEY'] || '1234567890'
  config.api_secret = ENV['CLOUDINARY_API_SECRET'] || 'secret'
  config.secure     = true
end
