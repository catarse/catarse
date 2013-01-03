class UpdateProjectsToStateMachineAgain < ActiveRecord::Migration
  def up
    execute(%Q{
      UPDATE projects 
        SET finished = true
        WHERE 
          finished = false AND visible = true AND expires_at <= current_timestamp - '5 days'::interval;
    })
    execute(%Q{
      UPDATE projects p
        SET state = (
              CASE
                WHEN p.finished = true AND p.successful = true THEN 'successful'
                WHEN p.finished = true AND p.successful = false THEN 'failed'
                WHEN p.finished = false AND p.visible = true THEN 'online'
                WHEN coalesce(p.visible, false) = false  THEN 'draft'
              END
            );
    })
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
