class Channels::Adm::StatisticsController < Adm::BaseController
  menu I18n.t('channels.adm.statistics_menu') => Rails.application.routes.url_helpers.adm_statistics_path

  actions :index

  before_filter do
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    @total_subscribers = @channel.subscribers.count
  end
end
