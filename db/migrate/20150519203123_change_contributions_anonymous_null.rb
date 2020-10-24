class ChangeContributionsAnonymousNull < ActiveRecord::Migration[4.2]
  def change
    change_column_null :contributions, :anonymous, false
  end
end
