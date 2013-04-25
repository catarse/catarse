class UpdateUserTotalToBackerStateMachine < ActiveRecord::Migration
  def up
    #20130423162359
    execute <<-SQL
      CREATE OR REPLACE VIEW user_totals AS 
      SELECT 
        b.user_id as id,
        b.user_id, 
        sum(b.value) AS sum, 
        count(*) AS count,
        sum(CASE 
          -- I've backed a successful (or unfinished) project with money
          WHEN (p.state <> 'failed') AND NOT b.credits THEN 0 
          -- I've backed a failed project with credits
          WHEN p.state = 'failed' AND b.credits THEN 0
          -- I've backed a failed project with money and asked for refund xor I've backed a failed project with credits
          WHEN p.state = 'failed' AND ((b.state='requested_refund' AND NOT b.credits) OR (b.credits AND NOT b.state='requested_refund')) THEN 0           
          -- I've backed a failed project with money and did not ask for refund
          WHEN p.state = 'failed' AND NOT b.credits AND b.state = 'confirmed' THEN b.value 
          -- I've backed a successful project with credits
          ELSE b.value * (-1)::numeric
        END) AS credits
      FROM 
        backers b
        JOIN projects p ON (b.project_id = p.id)
      WHERE b.state = 'confirmed'
      GROUP BY b.user_id;
    SQL
    
  end

  def down
    
    execute <<-SQL
      CREATE OR REPLACE VIEW user_totals AS 
      SELECT 
        b.user_id as id,
        b.user_id, 
        sum(b.value) AS sum, 
        count(*) AS count,
        sum(CASE 
          -- I've backed a successful (or unfinished) project with money
          WHEN (p.state <> 'failed') AND NOT b.credits THEN 0 
          -- I've backed a failed project with money and asked for refund xor I've backed a failed project with credits
          WHEN p.state = 'failed' AND ((b.requested_refund AND NOT b.credits) OR (b.credits AND NOT b.requested_refund)) THEN 0 
          -- I've backed a failed project with money and did not ask for refund
          WHEN p.state = 'failed' AND NOT b.credits AND NOT b.requested_refund THEN b.value 
          -- I've backed a successful project with credits
          ELSE b.value * (-1)::numeric
        END) AS credits
      FROM 
        backers b
        JOIN projects p ON (b.project_id = p.id)
      WHERE b.confirmed = true
      GROUP BY b.user_id;
    SQL
     
  end
end
