class SubdomainConstraint
  def self.matches?(request)
    User.with_permalink.pluck(:permalink).include? request.subdomain
  end
end
