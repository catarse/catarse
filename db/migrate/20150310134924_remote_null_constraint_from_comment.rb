class RemoteNullConstraintFromComment < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:project_posts, :comment, true)
  end
end
