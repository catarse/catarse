class ChangeContributionsAnonymousNull < ActiveRecord::Migration
  def change
    change_column_null :contributions, :anonymous, false
  end
end
