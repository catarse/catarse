class UpdateBackersThatAreInRefundedWhenProjectIsOnline < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      UPDATE backers
        SET state = 'refunded_and_canceled'
        WHERE state = 'refunded_when_project_is_not_finished'
    SQL
  end

  def down
    execute <<-SQL
      UPDATE backers
        SET state = 'refunded_when_project_is_not_finished'
        WHERE state = 'refunded_and_canceled'
    SQL
  end
end
