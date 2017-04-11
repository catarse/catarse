class AddProjectErrorsProjectidErrorIdx < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE INDEX project_errors_projectid_error_idx
      ON public.project_errors
      USING btree
      (project_id, error COLLATE pg_catalog."default");
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX project_errors_projectid_error_idx;
    SQL
  end
end
