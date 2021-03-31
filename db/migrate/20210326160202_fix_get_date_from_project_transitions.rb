class FixGetDateFromProjectTransitions < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.get_date_from_project_transitions(project_id integer, state text)
      RETURNS timestamp without time zone
      LANGUAGE sql
      STABLE
      AS $function$
            SELECT created_at
            FROM "1".project_transitions
            WHERE state = $2
            AND project_id = $1
            ORDER BY created_at DESC
            LIMIT 1
        $function$
      ;
    SQL
  end

  def down 
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.get_date_from_project_transitions(project_id integer, state text)
      RETURNS timestamp without time zone
      LANGUAGE sql
      STABLE
      AS $function$
              SELECT created_at
              FROM "1".project_transitions
              WHERE state = $2
              AND project_id = $1
          $function$
      ;
    SQL
  end
end
