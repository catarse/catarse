CarrierWave.configure do |config|
  if Rails.env.production? and Configuration[:aws_access_key]
      config.s3_access_key_id = Configuration[:aws_access_key]
      config.s3_secret_access_key = Configuration[:aws_secret_key]
      config.s3_bucket = Configuration[:aws_bucket]
  else
      config.storage = :file
      config.enable_processing = false if Rails.env.test? or Rails.env.cucumber?
  end
end