class AddReferalLinkOnBackers < ActiveRecord::Migration
  def change
    add_column :backers, :referal_link, :text
  end
end
