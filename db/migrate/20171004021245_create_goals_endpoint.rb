class CreateGoalsEndpoint < ActiveRecord::Migration[4.2]
  def change
    execute <<-SQL
    create or replace view "1".goals AS
    select g.id,
        g.project_id,
        g.description,
        g.title,
        g.value
        from goals g
        ;

    GRANT SELECT ON "1".goals TO anonymous, web_user, admin;
    SQL
  end
end
