class ChangeContributionsPayerNameNull < ActiveRecord::Migration
  def change
    execute "UPDATE contributions SET payer_name = (SELECT coalesce(name, email, 'Usuário ' || u.id::text) FROM users u WHERE u.id = contributions.user_id) WHERE payer_name IS NULL;"
    change_column_null :contributions, :payer_name, false
  end
end
