class AddPixQrcodeOnContributions < ActiveRecord::Migration[6.1]
  def change
    add_column :contributions, :count_contribution_canceled_pix, :integer, default: 0
  end
end
