class ChangeColumnToDateAndAddUidxProjectFiscals < ActiveRecord::Migration[6.1]
  def up
    change_column :project_fiscals, :begin_date, :date
    change_column :project_fiscals, :end_date, :date
    add_index :project_fiscals, %w[project_id begin_date end_date], unique: true, name: 'uidx_fiscal_begin_end_date'
  end

  def down
    change_column :project_fiscals, :begin_date, :datetime
    change_column :project_fiscals, :end_date, :datetime
    remove_index :project_fiscals, 'uidx_fiscal_begin_end_date'
  end
end
