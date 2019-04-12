# frozen_string_literal: true

class Origin < ActiveRecord::Base
  has_many :projects
  has_many :contributions

  #validates :domain, presence: true
  #validates :domain, uniqueness: { scope: :referral }
  validate :has_at_least_one_field

  def has_at_least_one_field
    if domain.blank? && referral.blank? && campaign.blank? && source.blank? && medium.blank? && content.blank? && term.blank?
        errors.add(:base, 'At least opne field should not be blank.')
    end
  end

  # Process a given ref and http referrer
  # until found or create a new Origin
  # { ref: referral, domain: 'domain' }
  def self.process_hash(hash = {})
    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',hash
    if !hash.nil? && (\
        !hash[:domain].blank?\
        || !hash[:ref].blank?\
        || !hash[:campaign].blank?\
        || !hash[:source].blank?\
        || !hash[:medium].blank?\
        || !hash[:content].blank?\
        || !hash[:term].blank? )
      o=find_or_create_by(\
        domain:   get_domain_from_url( hash[:domain] ),
        referral: hash[:ref],
        campaign: hash[:campaign],
        source:   hash[:source],
        medium:   hash[:medium] ,
        content:  hash[:content],
        term:     hash[:term]
      )
      p 'YYYYYYYYYYYYYYYYYYYYYYYYYY',o
      o
    end
  end

  protected

  def self.get_domain_from_url(url)
    if !url.blank?
      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") if uri.scheme.nil?
      host = uri.host.downcase
      host.start_with?('www.') ? host[4..-1] : host
    end
  end
end
