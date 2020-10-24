class AddUserTrigger < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL

CREATE OR REPLACE FUNCTION public.update_payments_full_text_index_from_user()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
     BEGIN
       update payments pa
       set full_text_index = public.generate_payments_full_text_index(pa.*)
       where pa.id in (SELECT p.id FROM payments p join contributions c on p.contribution_id = c.id WHERE c.user_id = NEW.id);
       return NULL;
     END;
    $function$;

    CREATE TRIGGER update_payments_full_text_index_from_user
    AFTER INSERT OR UPDATE OF name, email
    ON users FOR EACH ROW EXECUTE PROCEDURE update_payments_full_text_index_from_user();
    SQL
  end
end
