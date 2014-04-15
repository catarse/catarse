CarrierWave.configure do |config|
  if Rails.env.production? and CatarseSettings[:aws_access_key]
    config.fog_credentials = {
      provider: 'AWS',
      host: 's3.amazonaws.com',
      endpoint: '//s3.amazonaws.com',
      aws_access_key_id: CatarseSettings[:aws_access_key],
      aws_secret_access_key: CatarseSettings[:aws_secret_key]
    }
    config.fog_directory  = CatarseSettings[:aws_bucket]
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  else
    config.enable_processing = false if Rails.env.test? or Rails.env.cucumber?
  end
end
