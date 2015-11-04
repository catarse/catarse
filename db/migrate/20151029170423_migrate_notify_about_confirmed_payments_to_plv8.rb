class MigrateNotifyAboutConfirmedPaymentsToPlv8 < ActiveRecord::Migration
  def up
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.notify_about_confirmed_payments()
    RETURNS trigger
    LANGUAGE plv8
    AS $function$
            var sql = "SELECT " +
                            "u.thumbnail_image AS user_image, " +
                            "u.name AS user_name, " +
                            "p.thumbnail_image AS project_image, " +
                            "p.name AS project_name " +
                        "FROM contributions c " +
                        "JOIN users u on u.id = c.user_id " +
                        "JOIN projects p on p.id = c.project_id " +
                        "WHERE not c.anonymous and c.id = $1",
                contribution = plv8.execute(sql, [NEW.contribution_id]);

            if(contribution.length > 0){
                plv8.execute("SELECT pg_notify('new_paid_contributions', '" + JSON.stringify(contribution[0]) + "')");
            }

            return null;
    $function$
    SQL
  end

  def down
    execute <<-SQL
    CREATE OR REPLACE FUNCTION public.notify_about_confirmed_payments()
    RETURNS trigger
    LANGUAGE plpgsql
    AS $function$
            declare
            v_contribution json;
            begin
            v_contribution := (select
                json_build_object(
                    'user_image', u.thumbnail_image,
                    'user_name', u.name,
                    'project_image', p.thumbnail_image,
                    'project_name', p.name)
                from contributions c
                join users u on u.id = c.user_id
                join projects p on p.id = c.project_id
                where not c.anonymous and c.id = new.contribution_id);

            if v_contribution is not null then
                perform pg_notify('new_paid_contributions', v_contribution::text);
            end if;

            return null;
            end;
    $function$
    SQL
  end
end
