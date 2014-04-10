class Calendar
  attr_accessor :api_key, :max_results
  CALENDAR_API_URL = "https://www.googleapis.com/calendar/v3/"

  def initialize(api_key=nil, max_results=4)
    @api_key = api_key if api_key
    @api_key = CatarseSettings[:google_api_key]
    @max_results = max_results
  end

  def fetch_events_from(calendar_id)
    req = HTTParty.get(CALENDAR_API_URL+"calendars/#{calendar_id}/events?key=#{@api_key}&maxResults=#{@max_results}")
    if req.code == 200
      json = ActiveSupport::JSON.decode(req.body)
      return json['items']
    end
    []
  end
end
