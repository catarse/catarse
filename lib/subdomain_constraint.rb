module SubdomainConstraint
  class Users
    def self.matches?(request)
      if request.subdomain.present?
        User.with_permalink.where("lower(permalink) = lower(?)", request.subdomain).exists?
      end
    end
  end

  class Zelo
    def self.matches?(request)
      request.subdomain.present? && request.subdomain == CatarseSettings[:zelo_subdomain]
    end
  end
end
