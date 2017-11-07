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

  desc 'fetch all subscriptions'
  task fetch_subscriptions: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new(CatarseSettings[:common_api_key])
    page = 1
    per_page = page_size.to_i

    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        collection = cw.list_subscriptions(
          limit: page_size,
          offset: (page - 1) * per_page
        )

        if collection.empty?
          Rails.logger.info 'empty collection'
          break
        end

        Parallel.each(collection, in_threads: nthreads.to_i, progress: "feching subscriptions page #{page}") do |resource|
          subscription = ::Subscription.where.not(common_id: nil).find_by common_id: resource['id']
          user = User.where.not(common_id: nil).find_by common_id: resource['user_id']
          project = Project.where.not(common_id: nil).find_by common_id: resource['project_id']
          reward = Reward.where.not(common_id: nil).find_by common_id: resource['reward_id']

          if (user.present? && project.present?)
            if subscription.present?
              subscription.update_attributes(
                user_id: user.id,
                project_id: project.id,
                status: resource['status'],
                amount: resource['checkout_data']['amount'].to_f / 100.0,
                reward_id: reward.try(:id)
              )
            else
              subscription = Subscription.create(
                common_id: resource['id'],
                user_id: user.id,
                project_id: project.id,
                status: resource['status'],
                amount: resource['checkout_data']['amount'].to_f / 100.0,
                reward_id: reward.try(:id),
                created_at: resource['created_at']
              )
            end
            Rails.logger.info "subscription common id #{resource['id']} feteched into #{subscription.id} id"
          end
        end

        page += 1
      end
    end
  end

  desc 'fetch all subscription payments'
  task fetch_subscription_payments: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new(CatarseSettings[:common_api_key])
    page = 1
    per_page = page_size.to_i

    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        collection = cw.list_payments(
          limit: page_size,
          offset: (page - 1) * per_page
        )

        if collection.empty?
          Rails.logger.info 'empty collection'
          break
        end

        Parallel.each(collection, in_threads: nthreads.to_i, progress: "feching subscriptions page #{page}") do |resource|
          subscription = ::Subscription.where.not(common_id: nil).find_by common_id: resource['subscription_id']

          if subscription.present?
            subscription_payment = ::SubscriptionPayment.where.not(common_id: nil).find_by common_id: resource['id']

            if subscription_payment.present?
              subscription_payment.update_attributes(
                status: resource['status'],
                gateway_data: resource
              )
            else
              subscription_payment = subscription.subscription_payments.create(
                common_id: resource['id'],
                status: resource['status'],
                gateway_data: resource,
                created_at: resource['created_at']
              )
            end
            Rails.logger.info "subscription payment id #{resource['id']} feteched into #{subscription.id} id"
          end
        end

        page += 1
      end
    end
  end

  desc 'generate balance transaction for subscription payments'
  task generate_subscription_balance: :environment do
    SubscriptionPayment.where(status: 'paid').find_each do |sp|
      unless sp.already_in_balance?
        BalanceTransaction.insert_subscription_payment(sp.id)
      end
    end
  end

end
