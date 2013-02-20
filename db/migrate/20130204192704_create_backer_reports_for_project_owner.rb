class CreateBackerReportsForProjectOwner < ActiveRecord::Migration
  def up
    create_view :backer_reports_for_project_owners, "
    SELECT
      b.project_id,
      r.id as reward_id,
      r.description as reward_description,
      b.confirmed_at::date,
      b.value as back_value,
      (b.value* (SELECT value::numeric FROM configurations WHERE name = 'catarse_fee') ) as service_fee,
      u.email as user_email,
      b.payer_email as payer_email,
      b.payment_method,
      coalesce(b.address_street, u.address_street) as street,
      coalesce(b.address_complement, u.address_complement) as complement,
      coalesce(b.address_number, u.address_number) as address_number,
      coalesce(b.address_neighbourhood, u.address_neighbourhood) as neighbourhood,
      coalesce(b.address_city, u.address_city) as city,
      coalesce(b.address_state, u.address_state) as state,
      coalesce(b.address_zip_code, u.address_zip_code) as zip_code
    FROM
      backers b
    JOIN users u ON u.id = b.user_id
    LEFT JOIN rewards r ON r.id = b.reward_id
    WHERE
      b.confirmed;
    "
  end

  def down
    drop_view :backer_reports_for_project_owners
  end
end
