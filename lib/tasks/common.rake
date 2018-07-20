require './app/models/subscription'
namespace :common do
  desc 'index all users'
  task index_users: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new(CatarseSettings[:common_api_key])
    page = 1
    per_page = page_size.to_i
    total = User.where(common_id: nil).count
    total_pages = (total / per_page).round + 1

    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        collection = User.where(common_id: nil).order(id: :asc).limit(per_page).offset((page-1)*per_page)

        if collection.empty?
          Rails.logger.info 'empty users'
          break
        end

        Parallel.each(collection, in_threads: nthreads.to_i, progress: "indexing users page #{page}/#{total_pages}") do |user|
          indexed_id = cw.index_user(user)
          Rails.logger.info "indexing user #{user.id} on common id #{indexed_id}"
        end

        page += 1
      end
    end
  end

  desc 'index all projects'
  task index_projects: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new(CatarseSettings[:common_api_key])
    page = 1
    per_page = page_size.to_i
    total = Project.where(common_id: nil).count
    total_pages = (total / per_page).round + 1

    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        collection = Project.where(common_id: nil).order(id: :asc).limit(per_page).offset((page-1)*per_page)

        if collection.empty?
          Rails.logger.info 'empty collection'
          break
        end

        Parallel.each(collection, in_threads: nthreads.to_i, progress: "indexing projects page #{page}/#{total_pages}") do |resource|
          indexed_id = cw.index_project(resource)
          Rails.logger.info "indexing project #{resource.id} on common id #{indexed_id}"
        end

        page += 1
      end
    end
  end

  desc 'index all rewards'
  task index_rewards: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new(CatarseSettings[:common_api_key])
    page = 1
    per_page = page_size.to_i
    total = Reward.where(common_id: nil).count
    total_pages = (total / per_page).round + 1

    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        collection = Reward.where(common_id: nil).order(id: :asc).limit(per_page).offset((page-1)*per_page)

        if collection.empty?
          Rails.logger.info 'empty collection'
          break
        end

        Parallel.each(collection, in_threads: nthreads.to_i, progress: "indexing rewards page #{page}/#{total_pages}") do |resource|
          indexed_id = cw.index_reward(resource)
          Rails.logger.info "indexing reward #{resource.id} on common id #{indexed_id}"
        end

        page += 1
      end
    end
  end

  desc 'generate balance transaction for subscription payments'
  task generate_subscription_balance: :environment do
    ActiveRecord::Base.connection.execute("SET statement_timeout = '20s'")
    SubscriptionPayment.
      where('not exists(select true from balance_transactions where subscription_payment_uuid = catalog_payments.id)').
      where(platform_id: CatarseSettings[:common_platform_id], status: 'paid').
      find_each(batch_size: 20) do |sp|
      unless sp.already_in_balance?
        begin
          BalanceTransaction.insert_subscription_payment(sp.id)
        rescue Exception => e
          puts e.inspect
        end
      end
    end
  end

  desc 'generate common tables fdw'
  task generate_fdw: :environment do
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

      COMMIT;

    SQL
    # todo: when upgrade to 9.5+ can use this
    #IMPORT FOREIGN SCHEMA payment_service
    #  LIMIT TO (subscriptions, catalog_payments, payment_status_transitions, subscription_status_transitions)
    #  FROM SERVER common_db
    #  INTO common_schema;
  end

end
