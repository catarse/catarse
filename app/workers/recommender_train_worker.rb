# frozen_string_literal: true

class RecommenderTrainWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(user_id)
    common_wrapper = CommonWrapper.new()
    common_wrapper.train_recommender(User.find user_id)
  end
end
