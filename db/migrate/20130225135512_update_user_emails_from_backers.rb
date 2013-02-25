class UpdateUserEmailsFromBackers < ActiveRecord::Migration
  def up
    execute "
     UPDATE users 
     SET 
      email = (SELECT b.payer_email FROM backers b WHERE b.user_id = users.id AND b.payer_email IS NOT NULL LIMIT 1) 
     WHERE 
      email IS NULL 
      AND id IN (SELECT user_id FROM backers WHERE payer_email IS NOT NULL);
    "
  end

  def down
  end
end
