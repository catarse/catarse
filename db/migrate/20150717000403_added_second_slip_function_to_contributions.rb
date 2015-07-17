class AddedSecondSlipFunctionToContributions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.is_second_slip(contributions) RETURNS boolean
        LANGUAGE sql AS $_$
            select true where (
              select count(1) from payments p
                where p.contribution_id = $1.id
                and lower(p.payment_method) = 'boletobancario'
            ) >= 2
        $_$ STABLE;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION public.is_second_slip(contributions);
    SQL
  end
end
