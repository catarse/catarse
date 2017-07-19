# frozen_string_literal: true

# run with .pgpass file and command:
# DB_USER=dbuser DB_NAME=dnmame DB_HOST=localhost

set :job_template, nil
set :output, { standard: '~/cron.log' }

def generate_psql_c(view)
  only_view = view.split('.')[1]
  parsed_name = view.start_with?('"') ? view.inspect : view
  %{ echo "DO language plpgsql \\$\\$BEGIN
  RAISE NOTICE 'begin updating';
  IF NOT EXISTS (SELECT true FROM pg_stat_activity WHERE pg_backend_pid() <> pid AND query ~* 'refresh materialized .*#{only_view}') THEN
     RAISE NOTICE 'refreshing view';
     REFRESH MATERIALIZED VIEW CONCURRENTLY #{parsed_name};
    RAISE NOTICE 'view refreshed';
  END IF;
 END\\$\\$;" | psql -U #{ENV['DB_USER']} -h #{ENV['DB_HOST']} -d #{ENV['DB_NAME']}
}
end

%w[
  "1".finished_projects
  "1".statistics
  "1".statistics_music
  "1".category_totals
  "1".statistics_publicacoes
].each do |v|
  every 1.hour do
    command generate_psql_c(v)
  end
end

%w[
  "1".project_visitors_per_day
].each do |v|
  every 1.day, at: '11:59 pm' do
    command generate_psql_c(v)
  end
end

%w[
  "1".user_totals
].each do |v|
  every 10.minutes do
    command generate_psql_c(v)
  end
end

%w[
  public.moments_project_pageviews
  public.moments_project_pageviews_inferuser
  public.recommend_projects
  public.recommend_tanimoto_projects
  public.recommend_users
  public.recommend_tanimoto_user_contributions
  public.recommend_tanimoto_user_reminders
  public.recommend_tanimoto_user_visited
].each do |v|
  every 1.day, at: '00:30 am' do
    command generate_psql_c(v)
  end
end

%w[
  public.moments_navigations
  public.moments_project_start
  public.moments_project_start_inferuser
  stats.project_points
  stats.aarrr_realizador_draft_projetos
  stats.aarrr_realizador_online_projetos
  stats.aarrr_realizador_draft_by_category
  stats.aarrr_realizador_draft
  stats.aarrr_realizador_online_by_category
  stats.aarrr_realizador_online
  stats.growth_analise_tipo
  stats.growth_project_tags_weekly_contribs_mat
  stats.growth_project_views
  stats.growth_contributions
  stats.growth_contributions_confirmed
  stats.financeiro_control_panel_simplificado
  stats.financeiro_control_panel_simplificado_all_projects
  stats.financeiro_int_payments_2016_simplificado
  stats.financeiro_payment_refund_error_distribution
  stats.financeiro_payments_paid_refunded
  stats.financeiro_status_pagarme_catarse
].each do |v|
  every 1.day, at: '00:30 am' do
    command generate_psql_c(v)
  end
end
