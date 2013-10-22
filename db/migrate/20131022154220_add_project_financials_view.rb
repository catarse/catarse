class AddProjectFinancialsView < ActiveRecord::Migration
  def up
    execute "
      create or replace view project_financials as
        with catarse_fee_percentage as (
          select
            c.value::numeric as total,
            (1 - c.value::numeric) as complement
          from configurations c
          where c.name = 'catarse_fee'
        ), catarse_base_url as (
          select c.value from configurations c where c.name = 'base_url'
        )

        select
          p.id as project_id,
          p.name as name,
          u.moip_login as moip,
          p.goal as goal,
          pt.pledged as reached,
          pt.total_payment_service_fee as moip_tax,
          cp.total * pt.pledged as catarse_fee,
          pt.pledged * cp.complement as repass_value,
          to_char(p.expires_at, 'dd/mm/yyyy') as expires_at,
          catarse_base_url.value||'/admin/reports/backer_reports.csv?project_id='||p.id as backer_report,
          p.state as state
        from projects p
        join users u on u.id = p.user_id
        join project_totals pt on pt.project_id = p.id
        cross join catarse_fee_percentage cp
        cross join catarse_base_url
    "
  end

  def down
    execute "drop view project_financials"
  end
end
