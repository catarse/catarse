class AddTransferFullTextIndexes < ActiveRecord::Migration
  def change
    execute %Q{
CREATE OR REPLACE FUNCTION public.generate_transfer_full_text_index(bt balance_transfers)
    RETURNS tsvector
    LANGUAGE plpgsql
    STABLE
    AS $$
        DECLARE
            full_text_index tsvector;
            balance_owner public.users;
        BEGIN
            select * from users where id = bt.user_id into balance_owner;
            full_text_index := setweight(to_tsvector('portuguese', unaccent(coalesce(balance_owner.name, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(balance_owner.public_name, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(balance_owner.email::text, ''))), 'B') ||
                               setweight(to_tsvector('english', coalesce(
                                (
                                select array_agg(t.event_name)::text from (select btr.event_name
                                    from balance_transactions btr
                                    where btr.user_id = bt.user_id
                                    order by btr.id desc limit 10) t
                               ), '')), 'C') || 
                               setweight(to_tsvector('portuguese', unaccent(coalesce(bt.user_id::text, ''))), 'D') ||
                               setweight(to_tsvector('portuguese', coalesce(bt.transfer_id::text, '')), 'D');

            RETURN full_text_index;
        END;
$$;

create or replace function update_balance_transfer_full_text_index() returns trigger 
    language plpgsql
    as $$
        BEGIN
            NEW.full_text_index := public.generate_transfer_full_text_index(NEW.*);
            RETURN NEW;
        END;
    $$;

create trigger update_balance_transfer_full_text_index before insert or update on balance_transfers
    for each row execute procedure update_balance_transfer_full_text_index();
}
  end
end
