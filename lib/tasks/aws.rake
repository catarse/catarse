# frozen_string_literal: true

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
    new_bucket = Aws::S3::Bucket.new(CatarseSettings.get_without_cache(:aws_bucket), client: new_region)

    count = 0
    User.where('uploaded_image is not null').find_each do |user|
      key = user.uploaded_image.path
      fb_key = user.uploaded_image.versions[:thumb_facebook].try(:path)
      av_key = user.uploaded_image.versions[:thumb_avatar].try(:path)

      if new_bucket.object(key).exists? && new_bucket.object(fb_key).exists? && new_bucket.object(av_key).exists?
        print ".-#{user.id}"
      elsif old_bucket.object(key).exists?
        unless new_bucket.object(key).exists?
          new_bucket.object(key).copy_from(
            old_bucket.object(key)
          )
        end
        if !new_bucket.object(fb_key).exists? && old_bucket.object(fb_key).exists?
          new_bucket.object(fb_key).copy_from(
            old_bucket.object(fb_key)
          )
        end
        if !new_bucket.object(av_key).exists? && old_bucket.object(av_key).exists?
          new_bucket.object(av_key).copy_from(
            old_bucket.object(av_key)
          )
        end
        print "f-#{user.id}"
      else
        begin
          user.remove_uploaded_image!
        rescue
          nil
        end
        print "x-#{user.id}"
        count += 1
      end
    end
    puts count
  end
end
