class Channels::Adm::Reports::SubscribersReportController < Adm::Reports::BaseController
  require 'csv'
  before_filter do
    @channel  =  Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    respond_to do |format|
      format.csv do
        csv_string = CSV.generate do |csv|
          csv << ["name", "email", "link"]
          @channel.subscribers.each do |subscriber|
            csv << [
              subscriber.display_name,
              subscriber.email,
              user_url(subscriber)
            ]
          end
        end

        send_data csv_string,
                  type: 'text/csv; charset=iso-8859-1; header=present',
                  disposition: "attachment; filename=subscribers_report.csv"
      end
    end
  end
end
