class AddDefaultCreatedAt < ActiveRecord::Migration
  def up
    execute <<-SQL
     ALTER TABLE public.contributions ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.projects ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.payments ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.rewards ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.users ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.authorizations ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.bank_accounts ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.banks ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.categories ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.category_followers ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.category_notifications ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.channel_partners ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.channel_post_notifications ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.channel_posts ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.channels ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.settings ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.contribution_notifications ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.countries ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.credit_cards ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.dbhero_dataclips ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.oauth_providers ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.payment_notifications ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.project_accounts ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.project_budgets ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.project_notifications ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.project_post_notifications ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.project_posts ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.redactor_assets ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.states ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.unsubscribes ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.user_links ALTER created_at SET DEFAULT current_timestamp;
     ALTER TABLE public.user_notifications ALTER created_at SET DEFAULT current_timestamp;
    SQL
  end
end
