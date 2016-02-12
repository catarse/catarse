class AddColumnIpToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :ip_address, :text
    add_index :payments, :ip_address

    execute <<-SQL
CREATE OR REPLACE FUNCTION fill_user_ip_on_payments() RETURNS trigger
    STABLE LANGUAGE plpgsql
    AS $$
        BEGIN
            NEW.ip_address = (SELECT COALESCE(u.current_sign_in_ip, u.last_sign_in_ip)
                FROM contributions c
                JOIN users u on u.id = c.user_id
                WHERE c.id = NEW.contribution_id LIMIT 1);

            RETURN NEW;
        END;
    $$;

CREATE TRIGGER fill_user_ip_on_payments BEFORE INSERT ON public.payments
FOR EACH ROW EXECUTE PROCEDURE public.fill_user_ip_on_payments();
    SQL
  end

  def down
    remove_column :payments, :ip_address, :text
    execute <<-SQL
DROP TRIGGER fill_user_ip_on_payments ON public.payments;
DROP FUNCTION fill_user_ip_on_payments();
    SQL
  end
end
