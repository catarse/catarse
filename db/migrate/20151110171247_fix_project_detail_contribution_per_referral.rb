class FixProjectDetailContributionPerReferral < ActiveRecord::Migration
  def up
    execute <<-SQL
      create or replace view "1".project_contributions_per_ref as
        select
          i.project_id,
          json_agg(
            json_build_object(
                'referral_link', i.referral_link,
                'total', i.total,
                'total_amount', i.total_amount,
                'total_on_percentage', i.total_amount / (SELECT pledged FROM "1".project_totals pt WHERE pt.project_id = i.project_id) * 100
            )
          ) as source
        from
          (
            select
                c.project_id,
                c.referral_link::text as referral_link,
                count(c) as total,
                sum(c.value) as total_amount
            from 
                public.contributions c
            where
                c.was_confirmed
            group by 
                c.referral_link::text, 
                c.project_id
          ) as i
        group by i.project_id;
    SQL
  end

  def down
    execute <<-SQL
      create or replace view "1".project_contributions_per_ref as
        select
          i.project_id,
          json_agg(
            json_build_object('referral_link', i.referral_link, 'total', i.total, 'total_amount', i.total_amount, 'total_on_percentage', i.total_on_percentage)
          ) as source
        from (select
        c.project_id,
        c.referral_link::text as referral_link,
        count(c) as total,
        sum(c.value) as total_amount,
        (
			   (sum(c.value) * 100) / COALESCE(pt.pledged, 0)
	      )::numeric as total_on_percentage
        from 
        	contributions c
        join "1".project_totals pt on pt.project_id = c.project_id
        group by 
        	c.referral_link::text, 
        	c.project_id,
        	pt.pledged
        order by c.referral_link::text asc) as i
        group by i.project_id;
    SQL
  end
end
