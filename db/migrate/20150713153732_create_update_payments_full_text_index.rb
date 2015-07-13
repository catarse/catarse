class CreateUpdatePaymentsFullTextIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE INDEX payments_full_text_index_ix ON payments USING GIN (full_text_index);
    CREATE FUNCTION update_payments_full_text_index() RETURNS TRIGGER AS $$
     DECLARE
       v_contribution contributions;
     BEGIN
       SELECT * INTO v_contribution FROM contributions c WHERE c.id = NEW.contribution_id;
       NEW.full_text_index :=  setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.key::text, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.gateway::text, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.gateway_id::text, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(NEW.state::text, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce((NEW.gateway_data->>'acquirer_name'), ''))), 'B') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce((NEW.gateway_data->>'card_brand'), ''))), 'B') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce((NEW.gateway_data->>'tid'), ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(v_contribution.payer_email::text, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(v_contribution.payer_document::text, ''))), 'A') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(v_contribution.referral_link::text, ''))), 'B') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(v_contribution.user_id::text, ''))), 'B') ||
                               setweight(to_tsvector('portuguese', unaccent(coalesce(v_contribution.project_id::text, ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index || (SELECT full_text_index FROM projects p WHERE p.id = v_contribution.project_id);
       RETURN NEW;
     END;
    $$ LANGUAGE plpgsql;
    CREATE TRIGGER update_payments_full_text_index 
    BEFORE INSERT OR UPDATE OF key, gateway, gateway_id, gateway_data, state
    ON payments FOR EACH ROW EXECUTE PROCEDURE update_payments_full_text_index();
    SQL
  end

  def down
    execute <<-SQL
    DROP TRIGGER update_payments_full_text_index ON payments;
    DROP FUNCTION update_payments_full_text_index();
    DROP INDEX payments_full_text_index_ix;
    SQL
  end
end
