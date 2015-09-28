class CreatePaymentsReverseIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
    create unique index ON  payments (id desc);
    SQL
  end

  def down
    execute <<-SQL
    drop index payments_id_idx;
    SQL
  end
end
