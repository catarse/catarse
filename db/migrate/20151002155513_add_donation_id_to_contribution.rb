class AddDonationIdToContribution < ActiveRecord::Migration[4.2]
  def change
    add_reference :contributions, :donation
  end
end
