class RemoveAddressDependencies < ActiveRecord::Migration
  def change
    execute <<-SQL
    create or replace view "1".contribution_reports as
SELECT b.project_id,
    u.name,
    replace(b.value::text, '.'::text, ','::text) AS value,
    replace(r.minimum_value::text, '.'::text, ','::text) AS minimum_value,
    r.description,
    p.gateway,
    p.gateway_data -> 'acquirer_name'::text AS acquirer_name,
    p.gateway_data -> 'tid'::text AS acquirer_tid,
    p.payment_method,
    replace(p.gateway_fee::text, '.'::text, ','::text) AS payment_service_fee,
    p.key,
    b.created_at::date AS created_at,
    p.paid_at::date AS confirmed_at,
    u.email,
    b.payer_email,
    b.payer_name,
    COALESCE(b.payer_document, u.cpf) AS cpf,
    add.address_street,
    add.address_complement,
    add.address_number,
    add.address_neighbourhood,
    add.address_city,
    add.address_state,
    add.address_zip_code,
    p.state
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN payments p ON p.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN addresses add ON add.id = u.address_id

  WHERE p.state = ANY (ARRAY['paid'::character varying::text, 'refunded'::character varying::text, 'pending_refund'::character varying::text]);




  create or replace view contribution_reports_for_project_owners as
SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    r.deliver_at::date AS deliver_at,
    pa.paid_at::date AS confirmed_at,
    b.created_at::date AS created_at,
    pa.value AS contribution_value,
    pa.value * (( SELECT settings.value::numeric AS value
           FROM settings
          WHERE settings.name = 'catarse_fee'::text)) AS service_fee,
    u.email AS user_email,
    COALESCE(u.cpf, b.payer_document) AS cpf,
    u.name AS user_name,
    u.public_name,
    pa.gateway,
    b.anonymous,
    pa.state,
    waiting_payment(pa.*) AS waiting_payment,
    COALESCE(su.address ->> 'address_street'::text, add.address_street, b.address_street) AS street,
    COALESCE(su.address ->> 'address_complement'::text, add.address_complement, b.address_complement) AS complement,
    COALESCE(su.address ->> 'address_number'::text, add.address_number, b.address_number) AS address_number,
    COALESCE(su.address ->> 'address_neighbourhood'::text, add.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
    COALESCE(su.address ->> 'address_city'::text, add.address_city, b.address_city) AS city,
    COALESCE(su.state_name::text, add.address_state, b.address_state) AS address_state,
    COALESCE(su.address ->> 'address_zip_code'::text, add.address_zip_code, b.address_zip_code) AS zip_code,
        CASE
            WHEN sf.id IS NULL THEN ''::text
            ELSE (sf.destination || ' R$ '::text) || sf.value
        END AS shipping_choice,
    COALESCE(
        CASE
            WHEN r.shipping_options = 'free'::text THEN 'Sem frete envolvido'::text
            WHEN r.shipping_options = 'presential'::text THEN 'Retirada presencial'::text
            WHEN r.shipping_options = 'international'::text THEN 'Frete Nacional e Internacional'::text
            WHEN r.shipping_options = 'national'::text THEN 'Frete Nacional'::text
            ELSE NULL::text
        END, ''::text) AS shipping_option,
    su.open_questions,
    su.multiple_choice_questions,
    r.title
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN shipping_fees sf ON sf.id = b.shipping_fee_id
     LEFT JOIN "1".surveys su ON su.contribution_id = pa.contribution_id
     LEFT JOIN addresses add ON add.id = u.address_id
  WHERE pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]);

  create or replace view "1".contribution_reports_for_project_owners as
SELECT b.project_id,
    COALESCE(r.id, 0) AS reward_id,
    p.user_id AS project_owner_id,
    r.description AS reward_description,
    r.deliver_at::date AS deliver_at,
    pa.paid_at::date AS confirmed_at,
    pa.value AS contribution_value,
    pa.value * (( SELECT settings.value::numeric AS value
           FROM settings
          WHERE settings.name = 'catarse_fee'::text)) AS service_fee,
    u.email AS user_email,
    COALESCE(u.cpf, b.payer_document) AS cpf,
    u.name AS user_name,
    pa.gateway,
    b.anonymous,
    pa.state,
    waiting_payment(pa.*) AS waiting_payment,
    COALESCE(add.address_street, b.address_street) AS street,
    COALESCE(add.address_complement, b.address_complement) AS complement,
    COALESCE(add.address_number, b.address_number) AS address_number,
    COALESCE(add.address_neighbourhood, b.address_neighbourhood) AS neighbourhood,
    COALESCE(add.address_city, b.address_city) AS city,
    COALESCE(add.address_state, b.address_state) AS address_state,
    COALESCE(add.address_zip_code, b.address_zip_code) AS zip_code
   FROM contributions b
     JOIN users u ON u.id = b.user_id
     JOIN projects p ON b.project_id = p.id
     JOIN payments pa ON pa.contribution_id = b.id
     LEFT JOIN rewards r ON r.id = b.reward_id
     LEFT JOIN addresses add ON add.id = u.address_id
  WHERE pa.state = ANY (ARRAY['paid'::text, 'pending'::text, 'pending_refund'::text, 'refunded'::text]);





  create or replace view "1".project_accounts as
SELECT p.id,
    p.id AS project_id,
    p.user_id,
    u.email AS user_email,
    b.name AS bank_name,
    b.code AS bank_code,
    ba.agency,
    ba.agency_digit,
    ba.account,
    ba.account_digit,
    ba.account_type,
    u.name AS owner_name,
    u.cpf AS owner_document,
    u.state_inscription::text AS state_inscription,
    add.address_street,
    add.address_number,
    add.address_complement,
    add.address_neighbourhood,
    add.address_city,
    add.address_state,
    add.address_zip_code,
    add.phone_number,
    NULL::text AS error_reason,
    bt.state AS transfer_state,
    bt.transfer_limit_date,
    u.account_type AS user_type
   FROM projects p
     JOIN users u ON u.id = p.user_id
     LEFT JOIN bank_accounts ba ON u.id = ba.user_id
     LEFT JOIN addresses add ON add.id = u.address_id
     LEFT JOIN banks b ON b.id = ba.bank_id
     LEFT JOIN "1".balance_transfers bt ON bt.project_id = p.id
  WHERE is_owner_or_admin(p.user_id);



  create or replace view "1".team_totals as
SELECT count(DISTINCT u.id) AS member_count,
    array_to_json(array_agg(DISTINCT country.name)) AS countries,
    count(DISTINCT c.project_id) FILTER (WHERE was_confirmed(c.*)) AS total_contributed_projects,
    count(DISTINCT lower(unaccent(add.address_city))) AS total_cities,
    sum(c.value) FILTER (WHERE was_confirmed(c.*)) AS total_amount
   FROM users u
    LEFT join addresses add on add.id = u.address_id
     LEFT JOIN contributions c ON c.user_id = u.id
     LEFT JOIN countries country ON country.id = add.country_id
  WHERE u.admin;


  create or replace view "1".user_followers as
 SELECT uf.user_id,
    uf.follow_id,
    json_build_object('name', f.name, 'pulic_name', f.public_name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', add.address_city, 'state', st.acronym, 'following', user_following_this_user(uf.follow_id, uf.user_id)) AS source,
    zone_timestamp(uf.created_at) AS created_at,
    user_following_this_user(uf.follow_id, uf.user_id) AS following
   FROM user_follows uf
     LEFT JOIN "1".user_totals ut ON ut.user_id = uf.user_id
     JOIN users f ON f.id = uf.user_id
     LEFT JOIN addresses add ON f.address_id = add.id
     LEFT JOIN states st ON st.id = add.state_id
  WHERE is_owner_or_admin(uf.follow_id) AND f.deactivated_at IS NULL AND uf.follow_id IS NOT NULL;


  create or replace view "1".user_follows as
 SELECT uf.user_id,
    uf.follow_id,
    json_build_object('public_name', f.public_name, 'name', f.name, 'avatar', thumbnail_image(f.*), 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects, 'city', add.address_city, 'state', st.acronym) AS source,
    zone_timestamp(uf.created_at) AS created_at
   FROM user_follows uf
     LEFT JOIN "1".user_totals ut ON ut.user_id = uf.follow_id
     JOIN users f ON f.id = uf.follow_id
     LEFT JOIN addresses add ON f.address_id = add.id
     LEFT JOIN states st ON st.id = add.state_id
  WHERE is_owner_or_admin(uf.user_id) AND f.deactivated_at IS NULL;


  create or replace view "1".user_friends as
SELECT uf.user_id,
    uf.friend_id,
    user_following_this_user(uf.user_id, uf.friend_id) AS following,
    f.name,
    thumbnail_image(f.*) AS avatar,
    ut.total_contributed_projects,
    ut.total_published_projects,
    add.address_city AS city,
    st.acronym::text as state,
    f.public_name
   FROM user_friends uf
     LEFT JOIN "1".user_totals ut ON ut.user_id = uf.friend_id
     JOIN users f ON f.id = uf.friend_id
     LEFT JOIN addresses add ON f.address_id = add.id
     LEFT JOIN states st ON st.id = add.state_id
  WHERE is_owner_or_admin(uf.user_id) AND f.deactivated_at IS NULL;



  create or replace view "1".project_details as
SELECT p.id AS project_id,
    p.id,
    p.user_id,
    p.name,
    p.headline,
    p.budget,
    p.goal,
    p.about_html,
    p.permalink,
    p.video_embed_url,
    p.video_url,
    c.name_pt AS category_name,
    c.id AS category_id,
    original_image(p.*) AS original_image,
    thumbnail_image(p.*, 'thumb'::text) AS thumb_image,
    thumbnail_image(p.*, 'small'::text) AS small_image,
    thumbnail_image(p.*, 'large'::text) AS large_image,
    thumbnail_image(p.*, 'video_cover'::text) AS video_cover_image,
    COALESCE(pt.progress, 0::numeric) AS progress,
    COALESCE(
        CASE
            WHEN p.state::text = 'failed'::text THEN pt.pledged
            ELSE pt.paid_pledged
        END, 0::numeric) AS pledged,
    COALESCE(pt.total_contributions, 0::bigint) AS total_contributions,
    COALESCE(pt.total_contributors, 0::bigint) AS total_contributors,
    p.state::text AS state,
    p.mode,
    state_order(p.*) AS state_order,
    p.expires_at,
    zone_timestamp(p.expires_at) AS zone_expires_at,
    online_at(p.*) AS online_date,
    zone_timestamp(online_at(p.*)) AS zone_online_date,
    zone_timestamp(in_analysis_at(p.*)) AS sent_to_analysis_at,
    is_published(p.*) AS is_published,
    is_expired(p.*) AS is_expired,
    open_for_contributions(p.*) AS open_for_contributions,
    p.online_days,
    remaining_time_json(p.*) AS remaining_time,
    elapsed_time_json(p.*) AS elapsed_time,
    posts_size.count AS posts_count,
    json_build_object('city', ct.name, 'state_acronym', st.acronym, 'state', st.name) AS address,
    json_build_object('id', u.id, 'name', u.name, 'public_name', u.public_name) AS "user",
    ( SELECT count(DISTINCT pr_1.user_id) AS count
           FROM project_reminders pr_1
          WHERE pr_1.project_id = p.id) AS reminder_count,
    is_owner_or_admin(p.user_id) AS is_owner_or_admin,
    user_signed_in() AS user_signed_in,
    current_user_already_in_reminder(p.*) AS in_reminder,
    posts_size.count AS total_posts,
    p.state::text = 'successful'::text AND p.expires_at::date >= '2016-06-06'::date AS can_request_transfer,
    "current_user"() = 'admin'::name AS is_admin_role,
    (EXISTS ( SELECT true AS bool
           FROM contributions c_1
             JOIN user_follows uf ON uf.follow_id = c_1.user_id
          WHERE is_confirmed(c_1.*) AND uf.user_id = current_user_id() AND c_1.project_id = p.id)) AS contributed_by_friends,
        CASE
            WHEN "current_user"() = 'admin'::name THEN NULLIF(btrim(array_agg(DISTINCT admin_tags_lateral.tag_list)::text, '{}'::text), 'NULL'::text)
            ELSE NULL::text
        END AS admin_tag_list,
    NULLIF(btrim(array_agg(DISTINCT tags_lateral.tag_list)::text, '{}'::text), 'NULL'::text) AS tag_list,
    ct.id AS city_id,
        CASE
            WHEN "current_user"() = 'admin'::name THEN p.admin_notes
            ELSE NULL::text
        END AS admin_notes,
        CASE
            WHEN "current_user"() = 'admin'::name THEN p.service_fee
            ELSE NULL::numeric
        END AS service_fee
   FROM projects p
     JOIN categories c ON c.id = p.category_id
     JOIN users u ON u.id = p.user_id
     LEFT JOIN "1".project_totals pt ON pt.project_id = p.id
     LEFT JOIN cities ct ON ct.id = p.city_id
     LEFT JOIN states st ON st.id = ct.state_id
     LEFT JOIN LATERAL ( SELECT count(1) AS count
           FROM project_posts pp
          WHERE pp.project_id = p.id) posts_size ON true
     LEFT JOIN LATERAL ( SELECT t1.name AS tag_list
           FROM taggings tgs
             JOIN tags t1 ON t1.id = tgs.tag_id
          WHERE tgs.project_id = p.id AND tgs.tag_id IS NOT NULL) admin_tags_lateral ON true
     LEFT JOIN LATERAL ( SELECT pt1.name AS tag_list
           FROM taggings tgs
             JOIN public_tags pt1 ON pt1.id = tgs.public_tag_id
          WHERE tgs.project_id = p.id AND tgs.public_tag_id IS NOT NULL) tags_lateral ON true
  GROUP BY posts_size.count, ct.id, p.id, c.id, u.id, c.name_pt, ct.name,  st.acronym, st.name, pt.progress, pt.pledged, pt.paid_pledged, pt.total_contributions, p.state, p.expires_at, pt.total_payment_service_fee, pt.total_contributors;



  create or replace view "1".contributors as
SELECT u.id,
    u.id AS user_id,
    c.project_id,
    json_build_object('profile_img_thumbnail', thumbnail_image(u.*), 'public_name', u.public_name, 'name', u.name, 'city', add.address_city, 'state', st.acronym, 'total_contributed_projects', ut.total_contributed_projects, 'total_published_projects', ut.total_published_projects) AS data,
    (EXISTS ( SELECT true AS bool
           FROM user_follows uf
          WHERE uf.user_id = current_user_id() AND uf.follow_id = u.id)) AS is_follow
   FROM contributions c
     JOIN users u ON u.id = c.user_id
     left join addresses add on add.id = u.address_id
     left join states st on st.id = add.state_id
     JOIN projects p ON p.id = c.project_id
     JOIN "1".user_totals ut ON ut.user_id = u.id
  WHERE
        CASE
            WHEN p.state::text = 'failed'::text THEN was_confirmed(c.*)
            ELSE is_confirmed(c.*)
        END AND NOT c.anonymous AND u.deactivated_at IS NULL
  GROUP BY u.id, c.project_id, ut.total_contributed_projects, ut.total_published_projects, add.address_city, st.acronym;


  create or replace view "1".creator_suggestions as
SELECT u.id,
    u.id AS user_id,
    thumbnail_image(u.*) AS avatar,
    u.name,
    add.address_city AS city,
    st.acronym::text AS state,
    ut.total_contributed_projects,
    ut.total_published_projects,
    zone_timestamp(u.created_at) AS created_at,
    user_following_this_user(current_user_id(), u.id) AS following,
    u.public_name
   FROM contributions c
     JOIN projects p ON p.id = c.project_id
     JOIN users u ON u.id = p.user_id
     left join addresses add on add.id = u.address_id
     left join states st on st.id = add.state_id
     JOIN "1".user_totals ut ON ut.user_id = u.id
  WHERE was_confirmed(c.*) AND u.id <> current_user_id() AND c.user_id = current_user_id() AND u.deactivated_at IS NULL
  GROUP BY u.id, ut.total_contributed_projects, ut.total_published_projects, add.address_city, st.acronym;
    SQL
  end
end
