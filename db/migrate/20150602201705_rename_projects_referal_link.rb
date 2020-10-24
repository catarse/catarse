class RenameProjectsReferalLink < ActiveRecord::Migration[4.2]
  def change
    rename_column :projects, :referal_link, :referral_link
  end
end
