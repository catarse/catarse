if Rails.env.production? and Configuration.find_by_name('aws_access_key')
  begin
    CarrierWave.configure do |config|
      access_key = Configuration.find_by_name('aws_access_key')
      secret_key = Configuration.find_by_name('aws_secret_key')
      bucket = Configuration.find_by_name('aws_bucket')

      if access_key and secret_key and bucket
        config.s3_access_key_id = access_key.value
        config.s3_secret_access_key = secret_key.value
        config.s3_bucket = bucket.value
      end
    end
  rescue
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end