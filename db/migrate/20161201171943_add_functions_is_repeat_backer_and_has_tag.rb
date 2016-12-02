class AddFunctionsIsRepeatBackerAndHasTag < ActiveRecord::Migration
  def up
    execute <<-SQL
CREATE OR REPLACE FUNCTION public.is_repeat_backer(contributions) RETURNS boolean AS
$BODY$SELECT EXISTS (
  SELECT true
    FROM contributions c JOIN payments p
    ON c.id<>$1.id and c.user_id=$1.user_id and p.contribution_id=c.id and p.state=ANY(confirmed_states()) AND c.created_at<$1.created_at LIMIT 1
);$BODY$
LANGUAGE sql;
CREATE OR REPLACE FUNCTION public.has_admin_tag(projects, text) RETURNS boolean AS
$BODY$SELECT EXISTS (
  SELECT true FROM taggings tgg JOIN tags t ON tgg.project_id=$1.id AND tgg.tag_id=t.id AND t.slug=$2 LIMIT 1
);$BODY$
LANGUAGE sql;
    SQL
  end

  def down
    execute <<-SQL
DROP FUNCTION public.is_repeat_backer(contributions);
DROP FUNCTION public.has_tag(projects, text);
    SQL
  end
end
