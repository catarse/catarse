class AddReferalLinkIntoProjects < ActiveRecord::Migration
  def change
    add_column :projects, :referal_link, :text
  end
end
