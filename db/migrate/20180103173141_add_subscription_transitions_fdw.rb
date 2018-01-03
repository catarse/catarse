class AddSubscriptionTransitionsFdw < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE FOREIGN TABLE common_schema.subscription_status_transitions (
        id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
        subscription_id uuid NOT NULL,
        from_status payment_service.subscription_status NOT NULL,
        to_status payment_service.subscription_status NOT NULL,
        data jsonb DEFAULT '{}'::jsonb NOT NULL,
        created_at timestamp without time zone DEFAULT now() NOT NULL,
        updated_at timestamp without time zone DEFAULT now() NOT NULL
      ) SERVER common_db
      OPTIONS (schema_name 'payment_service', table_name 'subscription_status_transitions');
    SQL
  end
end
