class CreateShippingFeesEndpoint < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view "1".shipping_fees AS
    SELECT
    reward_id,
    destination,
    value,
    id
    from shipping_fees sf;


    grant all on shipping_fees to admin, web_user, anonymous;
    grant select, insert, update on "1".shipping_fees to admin, web_user;
    grant select on "1".shipping_fees to web_user, anonymous;

    SQL
  end
end
