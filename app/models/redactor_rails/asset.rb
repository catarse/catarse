class RedactorRails::Asset < ActiveRecord::Base
  include RedactorRails::Orm::ActiveRecord::AssetBase
  delegate :url, :current_path, :size, :content_type, :filename, :to => :data
  validates_presence_of :data
end
