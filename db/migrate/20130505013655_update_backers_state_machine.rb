class UpdateBackersStateMachine < ActiveRecord::Migration
  def up
    execute <<-SQL
      update backers b
        set state= 
        (
          case         
           -- when backer is via user credit
           when b.confirmed and b.credits then 'confirmed'            
           -- when backer is confirmed and user not requested refund and not is refunded and credits too
           when b.confirmed and not b.requested_refund and not b.refunded and not b.credits then 'confirmed'
           -- when backer is confirmed and user requested refund but is not refunded yet and not credits
           when b.confirmed and b.requested_refund and not b.refunded and not b.credits then 'requested_refund'
           -- when backer is refunded and not credits
           when b.confirmed and b.refunded and not b.credits then 'refunded'
           -- when backer is not confirmed but user already pass into payment gateway
           when not b.confirmed and b.payment_token is not null and ( 
             case 
               when lower(b.payment_choice) = 'debitobancario' then
                 date(current_timestamp) <= date(b.created_at + interval '1 days')
               when lower(b.payment_choice) = 'cartaodecredito' then
                 date(current_timestamp) <= date(b.created_at + interval '1 days')
               else
                 date(current_timestamp) <= date(b.created_at + interval '5 days')
               end
           ) then 'waiting_confirmation'
           else 'pending'
          end       
        )
    SQL
  end

  def down
  end
end
