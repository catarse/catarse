class CampaignFinisher

  def initialize collection = Project.to_finish
    @collection = collection
  end

  def start!
    @collection.each do |resource|
      Rails.logger.info "[FINISHING PROJECT #{resource.id}] #{resource.name}"
      resource.finish
    end
  end

end
