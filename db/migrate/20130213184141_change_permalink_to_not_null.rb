# encoding: utf-8
#
class ChangePermalinkToNotNull < ActiveRecord::Migration
  def up
    execute <<-SQL
    UPDATE projects SET permalink = regexp_replace(unaccent(lower(trim(name))), '[^\\w]|[ªº]', '-', 'gi') 
    WHERE NULLIF(trim(permalink), '') is NULL AND (SELECT count(*) < 2 FROM projects p2 
      WHERE regexp_replace(unaccent(lower(trim(p2.name))), '[^\\w]|[ªº]', '-', 'gi') = regexp_replace(unaccent(lower(trim(projects.name))), '[^\\w]|[ªº]', '-', 'gi'));
    UPDATE projects SET permalink = projects.id::text || '-' || regexp_replace(unaccent(lower(trim(name))), '[^\\w]|[ªº]', '-', 'gi') WHERE NULLIF(trim(permalink), '') is NULL;
    SQL
    change_column :projects, :permalink, :text, null: false
  end

  def down
    change_column :projects, :permalink, :string, null: true
  end
end
