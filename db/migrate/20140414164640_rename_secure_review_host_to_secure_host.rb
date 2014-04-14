class RenameSecureReviewHostToSecureHost < ActiveRecord::Migration
  def change
    execute "
    INSERT INTO settings (name, value, created_at, updated_at) SELECT 'secure_host', value, now(), now() FROM settings WHERE name = 'secure_review_host';
    DELETE FROM settings WHERE name = 'secure_review_host';
    "
  end
end
