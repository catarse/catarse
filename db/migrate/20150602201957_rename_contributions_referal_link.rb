class RenameContributionsReferalLink < ActiveRecord::Migration
  def change
    rename_column :contributions, :referal_link, :referral_link
  end
end
