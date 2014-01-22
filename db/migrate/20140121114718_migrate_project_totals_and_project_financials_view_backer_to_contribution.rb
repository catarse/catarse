class MigrateProjectTotalsAndProjectFinancialsViewBackerToContribution < ActiveRecord::Migration
  def up

    # project_totals VIEW
    execute <<-SQL
     DROP VIEW project_financials;
     DROP VIEW project_totals;
     CREATE OR REPLACE VIEW project_totals AS
       SELECT
         contributions.project_id,
         sum(contributions.value) AS pledged,
         (sum(contributions.value)/projects.goal)*100 as progress,
         sum(contributions.payment_service_fee) AS total_payment_service_fee,
        count(*) AS total_contributions
      FROM contributions
      JOIN projects ON contributions.project_id = projects.id
      WHERE (contributions.state in ('confirmed', 'refunded', 'requested_refund'))
      GROUP BY contributions.project_id, projects.goal;
      SQL

    # project_financials VIEW
    execute <<-SQL
     CREATE OR REPLACE VIEW project_financials AS
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
          catarse_base_url.value||'/admin/reports/contribution_reports.csv?project_id='||p.id as contribution_report,
          p.state as state
        from projects p
        join users u on u.id = p.user_id
        join project_totals pt on pt.project_id = p.id
        cross join catarse_fee_percentage cp
        cross join catarse_base_url;
      SQL
  end

  def down
    # project_totals VIEW
    execute <<-SQL
     DROP VIEW project_financials;
     DROP VIEW project_totals;
     CREATE OR REPLACE VIEW project_totals AS
       SELECT
         contributions.project_id,
         sum(contributions.value) AS pledged,
         (sum(contributions.value)/projects.goal)*100 as progress,
         sum(contributions.payment_service_fee) AS total_payment_service_fee,
        count(*) AS total_backers
      FROM contributions
      JOIN projects ON contributions.project_id = projects.id
      WHERE (contributions.state in ('confirmed', 'refunded', 'requested_refund'))
      GROUP BY contributions.project_id, projects.goal;
      SQL

    # project_financials VIEW
    execute <<-SQL
     CREATE OR REPLACE VIEW project_financials AS
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
        cross join catarse_base_url;
      SQL
  end
end
