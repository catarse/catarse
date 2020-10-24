class AddReferalLinkOnBackers < ActiveRecord::Migration[4.2]
  def change
    add_column :backers, :referal_link, :text
  end
end
