class CreateSendgridEvents < ActiveRecord::Migration
  def change
    create_table :sendgrid_events do |t|
      t.json :sendgrid_data

      t.timestamps
    end
  end
end
