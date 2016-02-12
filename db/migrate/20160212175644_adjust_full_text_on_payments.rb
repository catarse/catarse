class AdjustFullTextOnPayments < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION update_payments_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
     DECLARE
       v_contribution contributions;
       v_origin origins;
       v_user public.users;
     BEGIN
       SELECT * INTO v_contribution FROM contributions c WHERE c.id = NEW.contribution_id;
       SELECT * INTO v_origin FROM origins o WHERE o.id = v_contribution.origin_id;
       SELECT * INTO v_user FROM users u WHERE u.id = v_contribution.user_id;

       NEW.full_text_index :=  setweight(to_tsvector(unaccent(coalesce(NEW.key::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.gateway::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.gateway_id::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.state::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'acquirer_name'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'card_brand'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'tid'), ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_email::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_document::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.user_id::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.project_id::text, ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_origin.referral::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_origin.domain::text, ''))), 'B');
       NEW.full_text_index :=  NEW.full_text_index || 
                               setweight(to_tsvector(unaccent(coalesce(v_user.email::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_user.name::text, ''))), 'B');
       NEW.full_text_index :=  NEW.full_text_index || (SELECT full_text_index FROM projects p WHERE p.id = v_contribution.project_id);
       RETURN NEW;
     END;
    $$;
    SQL
  end

  def down
    execute <<-SQL
CREATE OR REPLACE FUNCTION update_payments_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
     DECLARE
       v_contribution contributions;
       v_origin origins;
       v_name text;
     BEGIN
       SELECT * INTO v_contribution FROM contributions c WHERE c.id = NEW.contribution_id;
       SELECT * INTO v_origin FROM origins o WHERE o.id = v_contribution.origin_id;
       SELECT u.name INTO v_name FROM users u WHERE u.id = v_contribution.user_id;

       NEW.full_text_index :=  setweight(to_tsvector(unaccent(coalesce(NEW.key::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.gateway::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.gateway_id::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(NEW.state::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'acquirer_name'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'card_brand'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((NEW.gateway_data->>'tid'), ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_email::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_document::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.user_id::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.project_id::text, ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_origin.referral::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_origin.domain::text, ''))), 'B');
       NEW.full_text_index :=  NEW.full_text_index || setweight(to_tsvector(unaccent(coalesce(v_name::text, ''))), 'A');
       NEW.full_text_index :=  NEW.full_text_index || (SELECT full_text_index FROM projects p WHERE p.id = v_contribution.project_id);
       RETURN NEW;
     END;
    $$;

    SQL
  end
end
