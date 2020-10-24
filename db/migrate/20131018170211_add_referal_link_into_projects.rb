class AddReferalLinkIntoProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :referal_link, :text
  end
end
