namespace :common do
  desc 'index all users'
  task index_users: :environment do
    nthreads = ENV['COMMON_INDEXER_NTHREADS'].presence || 3
    page_size = ENV['COMMON_INDEXER_PAGE_SIZE'].presence || 500
    cw = CommonWrapper.new(CatarseSettings[:common_api_key])
    page = 1
    per_page = page_size.to_i
    total = User.count
    total_pages = (total / per_page).to_i
    loop do
      collection = User.order(id: :asc).limit(per_page).offset((page-1)*per_page)

      if collection.empty?
        Rails.logger.info 'empty users'
        break
      end

      Parallel.each(collection, in_threads: nthreads.to_i, progress: "indexing users page #{page}/#{total_pages}") do |user|
        ActiveRecord::Base.connection_pool.with_connection do
          indexed_id = cw.index_user(user)
          Rails.logger.info "indexing user #{user.id} on common id #{indexed_id}"
        end
      end

      page += 1
    end
  end
end
