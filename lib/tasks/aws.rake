namespace :aws do
  desc 'check for not found images'
  task check_missing_user_imgs: :environment do
    Aws.config[:credentials] = Aws::Credentials.new(
      CatarseSettings.get_without_cache(:aws_access_key),
      CatarseSettings.get_without_cache(:aws_secret_key)
    )

    old_region = Aws::S3::Client.new(region: 'us-east-1')
    new_region = Aws::S3::Client.new(region: 'sa-east-1')

    old_bucket = Aws::S3::Bucket.new(CatarseSettings.get_without_cache(:aws_old_bucket), client: old_region)
    new_bucket =  Aws::S3::Bucket.new(CatarseSettings.get_without_cache(:aws_bucket), client: new_region)

    count = 0
    User.where("uploaded_image is not null").find_each do |user| 
      key = user.uploaded_image.path

      if new_bucket.object(key).exists?
        print ".-#{user.id}"
      else if old_bucket.object(key).exists?
        new_bucket.object(key).copy_from(
          old_bucket.object(key)
        )
        print "f-#{user.id}"
      else
        print "x-#{user.id}"
        count += 1
      end
    end
    puts count
  end
end
