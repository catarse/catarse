class AddDonationIdToContribution < ActiveRecord::Migration
  def change
    add_reference :contributions, :donation
  end
end
