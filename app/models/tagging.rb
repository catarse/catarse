class Tagging < ActiveRecord::Base
  belongs_to :project
  belongs_to :tag
  belongs_to :public_tag

end
