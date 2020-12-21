class AddCityToProjects < ActiveRecord::Migration[4.2]
  def change
    add_reference :projects, :city, index: true
  end
end
