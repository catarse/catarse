class RemoteNullConstraintFromComment < ActiveRecord::Migration
  def change
    change_column_null(:project_posts, :comment, true)
  end
end
