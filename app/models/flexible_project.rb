class FlexibleProject < ActiveRecord::Base
  belongs_to :project

  # ensure that we have only one flexible project per project
  validates :project_id, presence: true, uniqueness: true

end
