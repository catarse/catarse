class AddCanRefundFunctionToBackers < ActiveRecord::Migration
  def up
    execute "
      create function can_refund(backers) returns boolean as $$
        select
          $1.state IN('confirmed', 'requested_refund', 'refunded') AND
          NOT $1.credits AND
          EXISTS(
            SELECT true
              FROM projects p
              WHERE p.id = $1.project_id and p.state = 'failed'
          )
      $$ language sql
    "
  end

  def down
    execute "drop function can_refund(backers);"
  end
end
