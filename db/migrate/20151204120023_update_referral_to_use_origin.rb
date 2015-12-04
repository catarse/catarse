class UpdateReferralToUseOrigin < ActiveRecord::Migration
  def up
    execute " set statement_timeout to 0;"
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

CREATE OR REPLACE VIEW "1".project_contributions_per_ref AS
 SELECT i.project_id,
    json_agg(
        json_build_object(
            'referral_link', i.referral_link,
            'total', i.total,
            'total_amount', i.total_amount,
            'total_on_percentage', (
                (i.total_amount / (
                    SELECT pt.pledged
                    FROM "1".project_totals pt
                    WHERE (pt.project_id = i.project_id))
                ) * (100)::numeric)
            )
        ) AS source
    FROM (
            SELECT c.project_id,
                coalesce(o.referral, o.domain) as referral_link,
                count(c.*) AS total,
                sum(c.value) AS total_amount
            FROM public.contributions c
            LEFT JOIN origins o on o.id = c.origin_id
            WHERE public.was_confirmed(c.*)
            GROUP BY o.referral, o.domain, c.project_id
        ) i
  GROUP BY i.project_id;

CREATE OR REPLACE VIEW "1".referral_totals AS
 SELECT to_char(c.created_at, 'YYYY-MM'::text) AS month,
    coalesce(nullif(o.referral, ''), o.domain) as referral_link,
    p.permalink,
    count(*) AS contributions,
    count(*) FILTER (WHERE public.was_confirmed(c.*)) AS confirmed_contributions,
    COALESCE(sum(c.value) FILTER (WHERE public.was_confirmed(c.*)), (0)::numeric) AS confirmed_value
   FROM public.contributions c
     JOIN public.projects p ON p.id = c.project_id
     LEFT JOIN public.origins o ON o.id = c.origin_id
  GROUP BY to_char(c.created_at, 'YYYY-MM'::text), coalesce(nullif(o.referral, ''), o.domain), p.permalink;

    SQL
  end

  def down
    execute " set statement_timeout to 0;"
    execute <<-SQL
CREATE OR REPLACE VIEW "1".project_contributions_per_ref AS
 SELECT i.project_id,
    json_agg(json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', ((i.total_amount / ( SELECT pt.pledged
           FROM "1".project_totals pt
          WHERE (pt.project_id = i.project_id))) * (100)::numeric))) AS source
   FROM ( SELECT c.project_id,
            c.referral_link,
            count(c.*) AS total,
            sum(c.value) AS total_amount
           FROM public.contributions c
          WHERE public.was_confirmed(c.*)
          GROUP BY c.referral_link, c.project_id) i
  GROUP BY i.project_id;

CREATE OR REPLACE VIEW "1".referral_totals AS
 SELECT to_char(c.created_at, 'YYYY-MM'::text) AS month,
    c.referral_link,
    p.permalink,
    count(*) AS contributions,
    count(*) FILTER (WHERE public.was_confirmed(c.*)) AS confirmed_contributions,
    COALESCE(sum(c.value) FILTER (WHERE public.was_confirmed(c.*)), (0)::numeric) AS confirmed_value
   FROM (public.contributions c
     JOIN public.projects p ON ((p.id = c.project_id)))
  WHERE (NULLIF(c.referral_link, ''::text) IS NOT NULL)
  GROUP BY to_char(c.created_at, 'YYYY-MM'::text), c.referral_link, p.permalink;

CREATE OR REPLACE FUNCTION update_payments_full_text_index() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
     DECLARE
       v_contribution contributions;
       v_name text;
     BEGIN
       SELECT * INTO v_contribution FROM contributions c WHERE c.id = NEW.contribution_id;
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
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.referral_link::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.user_id::text, ''))), 'B') ||
                               setweight(to_tsvector(unaccent(coalesce(v_contribution.project_id::text, ''))), 'C');
       NEW.full_text_index :=  NEW.full_text_index || setweight(to_tsvector(unaccent(coalesce(v_name::text, ''))), 'A');
       NEW.full_text_index :=  NEW.full_text_index || (SELECT full_text_index FROM projects p WHERE p.id = v_contribution.project_id);
       RETURN NEW;
     END;
    $$;

    SQL
  end
end
