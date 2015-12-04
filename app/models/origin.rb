class Origin < ActiveRecord::Base
  has_many :projects
  has_many :contributions

  validates :domain, presence: true
  validates :domain, uniqueness: { scope: :referral }


  # Process a given ref and http referrer
  # until found or create a new Origin
  # { ref: referral, domain: 'domain' }
  def self.process_hash hash = {}
    find_or_create_by(
      referral: hash[:ref],
      domain: get_domain_from_url(hash[:domain])
    ) if hash[:domain].present?
  end

  protected

  def self.get_domain_from_url(url)
    uri = URI.parse(url)
    uri = URI.parse("http://#{url}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end
end
