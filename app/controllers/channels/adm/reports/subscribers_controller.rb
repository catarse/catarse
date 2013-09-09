class Channels::Adm::Reports::SubscribersController < Adm::Reports::BaseController
  def begin_of_association_chain
    Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def end_of_association_chain
    super.select("users.name, users.email")
  end
end
