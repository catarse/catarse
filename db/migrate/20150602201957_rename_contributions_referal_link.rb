class RenameContributionsReferalLink < ActiveRecord::Migration[4.2]
  def change
    rename_column :contributions, :referal_link, :referral_link
  end
end
