namespace :common do
  desc 'generate common tables fdw'
  task generate_fdw: :environment do
    if CatarseSettings[:generate_fdw_task_runned] == true
      puts 'generate_fdw already runned'
    else
      ActiveRecord::Base.connection.execute <<-SQL
        BEGIN;
        CREATE EXTENSION IF NOT EXISTS postgres_fdw;
        DROP SERVER IF EXISTS common_db CASCADE;
        CREATE SERVER common_db
          FOREIGN DATA WRAPPER postgres_fdw
          OPTIONS (host '#{CatarseSettings[:common_db_host]}', dbname '#{CatarseSettings[:common_db_name]}', port '#{CatarseSettings[:common_db_port]}');
        CREATE USER MAPPING FOR #{CatarseSettings[:fdw_user]}
          SERVER common_db
          OPTIONS (user '#{CatarseSettings[:common_db_user]}', password '#{CatarseSettings[:common_db_password]}');

        CREATE USER MAPPING FOR catarse
          SERVER common_db
          OPTIONS (user '#{CatarseSettings[:common_db_user]}', password '#{CatarseSettings[:common_db_password]}');

        DROP SCHEMA IF EXISTS common_schema CASCADE;
        CREATE SCHEMA common_schema;
        DROP SCHEMA IF EXISTS payment_service CASCADE;
        CREATE SCHEMA payment_service;

        CREATE TYPE payment_service.payment_status AS ENUM (
            'pending',
            'paid',
            'refused',
            'refunded',
            'chargedback',
            'deleted',
            'error'
        );

        CREATE TYPE payment_service.subscription_status AS ENUM (
            'started',
            'active',
            'inactive',
            'canceled',
            'deleted',
            'error'
        );

        CREATE FOREIGN TABLE common_schema.subscriptions (
            id uuid NOT NULL,
            platform_id uuid NOT NULL,
            project_id uuid NOT NULL,
            user_id uuid NOT NULL,
            reward_id uuid,
            credit_card_id uuid,
            status payment_service.subscription_status NOT NULL,
            created_at timestamp without time zone NOT NULL,
            updated_at timestamp without time zone NOT NULL,
            checkout_data jsonb NOT NULL
        ) SERVER common_db
        OPTIONS (schema_name 'payment_service', table_name 'subscriptions');
        ;

        CREATE FOREIGN TABLE common_schema.catalog_payments (
            id uuid NOT NULL,
            platform_id uuid NOT NULL,
            project_id uuid NOT NULL,
            user_id uuid NOT NULL,
            subscription_id uuid,
            reward_id uuid,
            data jsonb NOT NULL,
            gateway text NOT NULL,
            gateway_cached_data jsonb,
            created_at timestamp without time zone NOT NULL,
            updated_at timestamp without time zone NOT NULL,
            common_contract_data jsonb NOT NULL,
            gateway_general_data jsonb NOT NULL,
            status payment_service.payment_status NOT NULL,
            external_id text,
            error_retry_at timestamp without time zone
        ) SERVER common_db 
        OPTIONS (schema_name 'payment_service', table_name 'catalog_payments');

        CREATE FOREIGN TABLE common_schema.payment_status_transitions (
            id uuid NOT NULL,
            catalog_payment_id uuid NOT NULL,
            from_status payment_service.payment_status NOT NULL,
            to_status payment_service.payment_status NOT NULL,
            data jsonb NOT NULL,
            created_at timestamp without time zone NOT NULL,
            updated_at timestamp without time zone NOT NULL
        ) SERVER common_db
        OPTIONS (schema_name 'payment_service', table_name 'payment_status_transitions');

        CREATE FOREIGN TABLE common_schema.antifraud_analyses (
          id uuid NOT NULL,
          catalog_payment_id uuid NOT NULL,
          cost numeric NOT NULL ,
          data jsonb DEFAULT '{}'::jsonb NOT NULL,
          created_at timestamp without time zone NOT NULL,
          updated_at timestamp without time zone NOT NULL
        ) SERVER common_db
        OPTIONS (schema_name 'payment_service', table_name 'antifraud_analyses');

        COMMIT;
      SQL

      CatarseSettings[:generate_fdw_task_runned] = true
    end

      # todo: when upgrade to 9.5+ can use this
      #IMPORT FOREIGN SCHEMA payment_service
      #  LIMIT TO (subscriptions, catalog_payments, payment_status_transitions, subscription_status_transitions)
      #  FROM SERVER common_db
      #  INTO common_schema;
  end
end
