class SubdomainConstraint
  def self.matches?(request)
    if request.subdomain.present?
      User.with_permalink.where("lower(permalink) = lower(?)", request.subdomain).exists?
    end
  end
end
