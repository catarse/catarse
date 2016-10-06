class AbstrasctPaymentFullTextIndexGeneration < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.update_payments_full_text_index()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
     BEGIN
       NEW.full_text_index := public.generate_payments_full_text_index(NEW.*);
       RETURN NEW;
     END;
    $function$;


CREATE OR REPLACE FUNCTION public.generate_payments_full_text_index(payment public.payments)
 RETURNS tsvector
 LANGUAGE plpgsql
AS $function$
     DECLARE
       v_full_text_index tsvector;
       v_contribution contributions;
       v_origin origins;
       v_user public.users;
     BEGIN
       SELECT * FROM contributions c WHERE c.id = payment.contribution_id INTO v_contribution;
       SELECT * FROM origins o WHERE o.id = v_contribution.origin_id INTO v_origin;
       SELECT * FROM users u WHERE u.id = v_contribution.user_id INTO v_user ;

       v_full_text_index :=  setweight(to_tsvector(unaccent(coalesce(payment.key::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(payment.gateway::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(payment.gateway_id::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(payment.state::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce((payment.gateway_data->>'acquirer_name'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((payment.gateway_data->>'card_brand'), ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce((payment.gateway_data->>'tid'), ''))), 'C');

       v_full_text_index :=  v_full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_email::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.payer_document::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.user_id::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.project_id::text, ''))), 'C');

       v_full_text_index :=  v_full_text_index ||
                               setweight(to_tsvector(unaccent(coalesce(v_origin.referral::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_origin.domain::text, ''))), 'B');

       v_full_text_index :=  v_full_text_index || 
                               setweight(to_tsvector(unaccent(coalesce(v_user.email::text, ''))), 'A') ||
                               setweight(to_tsvector(unaccent(coalesce(v_user.name::text, ''))), 'B');

       v_full_text_index :=  v_full_text_index || coalesce((SELECT full_text_index FROM projects p WHERE p.id = v_contribution.project_id limit 1), '');

       RETURN v_full_text_index;
     END;
    $function$
;

    }
  end

  def down
    execute %Q{
    CREATE OR REPLACE FUNCTION public.update_payments_full_text_index()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
    $function$;

    }
  end
end
