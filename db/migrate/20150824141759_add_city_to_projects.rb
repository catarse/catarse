class AddCityToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :city, index: true
  end
end
