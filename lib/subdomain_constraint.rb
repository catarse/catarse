class SubdomainConstraint
  def self.matches?(request)
    User.with_permalink.where("lower(permalink) = lower(?)", request.subdomain).exists?
  end
end
