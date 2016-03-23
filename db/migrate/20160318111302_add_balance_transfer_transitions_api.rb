class AddBalanceTransferTransitionsApi < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPlACE VIEW "1".balance_transfer_transitions AS
    SELECT
        bt.project_id,
        btt.balance_transfer_id,
        bt.user_id,
        btt.to_state as state,
        btt.metadata,
        btt.most_recent,
        btt.created_at
    FROM public.balance_transfer_transitions btt
    JOIN public.balance_transfers bt ON bt.id = btt.balance_transfer_id
    WHERE public.is_owner_or_admin(bt.user_id);

GRANT SELECT ON "1".balance_transfer_transitions TO web_user, admin;
    SQL
  end

  def down
    execute <<-SQL
DROP VIEW "1".balance_transfer_transitions;
    SQL
  end
end
