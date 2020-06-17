require './app/models/subscription'
namespace :common do
  desc 'index all users'
  task index_users: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new()
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
    cw = CommonWrapper.new()
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

  def index_model(collection)
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    page = 1
    per_page = page_size.to_i
    total = collection.count
    total_pages = (total / per_page).round + 1

    ActiveRecord::Base.connection_pool.with_connection do
      loop do
        collection = collection.order(id: :asc).limit(per_page).offset((page-1)*per_page)

        if collection.empty?
          Rails.logger.info 'empty collection'
          break
        end

        Parallel.each(collection, in_threads: nthreads.to_i, progress: "indexing #{collection.model_name.name} page #{page}/#{total_pages}") do |resource|
          indexed_id = yield(resource)
          Rails.logger.info "indexing #{collection.model_name.name} #{resource.id} on common id #{indexed_id}"
        end

        page += 1
      end
    end
  end

  desc 'index all posts'
  task index_posts: :environment do
    cw = CommonWrapper.new()
    collection = ProjectPost.where(common_id: nil)
    index_model(collection) { |resource| cw.index_project_post(resource) }
  end

  desc 'index all goals'
  task index_goals: :environment do
    cw = CommonWrapper.new()
    collection = Goal.where(common_id: nil)
    index_model(collection) { |resource| cw.index_goal(resource) }
  end


  desc 'index all rewards'
  task index_goals: :environment do
    cw = CommonWrapper.new()
    collection = Reward.where(common_id: nil)
    index_model(collection) { |resource| cw.index_reward(resource) }
  end

  desc 'generate balance transaction for subscription payments'
  task generate_subscription_balance: :environment do
    SubscriptionPayment.select("id, reward_id").
      where('not exists(select true from balance_transactions where subscription_payment_uuid = catalog_payments.id)').
      where(platform_id: CatarseSettings[:common_platform_id], status: 'paid').each do |sp|
      unless sp.already_in_balance?
        begin
          BalanceTransaction.insert_subscription_payment(sp.id)
          RewardMetricStorage.perform_async(sp.reward_id)
        rescue StandardError => e
          Raven.extra_context(task: :generate_subscription_balance, subscription_payment_id: sp.id)
          Raven.capture_exception(e)
          Raven.extra_context({})
        end
      end
    end
  end

end
