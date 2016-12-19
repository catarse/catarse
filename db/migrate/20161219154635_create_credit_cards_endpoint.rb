class CreateCreditCardsEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE VIEW "1".user_credit_cards AS
    select id, user_id,last_digits, card_brand from credit_cards cc
    where is_owner_or_admin(cc.user_id);

    GRANT SELECT ON "1".user_credit_cards to admin;
    GRANT SELECT ON "1".user_credit_cards to web_user;
    SQL
  end
end
