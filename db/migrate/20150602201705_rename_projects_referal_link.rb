class RenameProjectsReferalLink < ActiveRecord::Migration
  def change
    rename_column :projects, :referal_link, :referral_link
  end
end
