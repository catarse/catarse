class CreateBackerReports < ActiveRecord::Migration
  def up
    create_view :backer_reports, "
    SELECT 
      b.project_id,
      u.name, 
      b.value,
      r.minimum_value,
      r.description,
      b.payment_method,
      b.payment_choice,
      b.payment_service_fee,
      b.key,
      b.created_at::date,
      b.confirmed_at::date,
      u.email,
      b.payer_email,
      b.payer_name,
      u.cpf,
      u.address_street,
      u.address_complement,
      u.address_number,
      u.address_neighbourhood,
      u.address_city,
      u.address_state,
      u.address_zip_code,
      b.requested_refund,
      b.refunded
    FROM 
      backers b
      JOIN users u ON u.id = b.user_id
      LEFT JOIN rewards r ON r.id = b.reward_id
    WHERE
      b.confirmed;
    "
  end

  def down
    drop_view :backer_reports
  end
end
