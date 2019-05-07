class RefactorOrigins < ActiveRecord::Migration
  def up
    execute <<-SQL
        DROP INDEX public.index_origins_on_domain_and_referral;
        ALTER TABLE public.origins
            ALTER COLUMN domain DROP NOT NULL,
            ADD COLUMN campaign text,
            ADD COLUMN source text,
            ADD COLUMN medium text,
            ADD COLUMN content text,
            ADD COLUMN term text;
        CREATE UNIQUE INDEX origins_uniq_idx on public.origins(domain,referral,campaign,source,medium,content,term);
    ;
    SQL
  end

  def down
    execute <<-SQL
        DROP INDEX origins_uniq_idx;
        ALTER TABLE public.origins
            DROP COLUMN campaign,
            DROP COLUMN source,
            DROP COLUMN medium,
            DROP COLUMN content,
            DROP COLUMN term;
        --DELETE FROM public.origins where domain is null;
        ALTER TABLE public.origins
            ALTER COLUMN domain SET NOT NULL;
        CREATE UNIQUE INDEX index_origins_on_domain_and_referral on public.origins(domain,referral);
    SQL
  end
end
