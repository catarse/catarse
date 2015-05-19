class ChangeContributionsPayerEmailNull < ActiveRecord::Migration
  def change
    execute "UPDATE contributions SET payer_email = (SELECT coalesce(email, 'usuario+sem+email@catarse.me') FROM users u WHERE u.id = contributions.user_id) WHERE payer_email IS NULL;"
    change_column_null :contributions, :payer_email, false
  end
end
