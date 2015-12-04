class PermalinkNotNull < ActiveRecord::Migration
  def up
    execute "set statement_timeout to 0;"

    execute <<-SQL
update projects set permalink = 'project_' || id::text,
  about_html = coalesce(about_html, name),
  headline = coalesce(headline, name),
  uploaded_image = coalesce(uploaded_image, 'missing_image')
where not permalink ~* '\\A(\\w|-)+\\Z';

alter table projects
  alter column permalink set default 'project_' || currval('projects_id_seq')::text;

alter table projects
  add constraint permalinkck check (permalink ~* '\\A(\\w|-)+\\Z');
    SQL
  end

  def down
    change_column_default :projects, :permalink, nil
    execute <<-SQL
alter table projects
  drop constraint if exists permalinkck;
    SQL
  end
end
