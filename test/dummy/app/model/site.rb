require 'subdomain_site/acts_as_site'
require 'active_model'
class Site
  include ActiveModel::Model
  include SubdomainSite::ActsAsSite

  attr_accessor :subdomain
  acts_as_site

  def persisted?
    true
  end

  def self.find_by_subdomain(subdomain)
    sites[subdomain.to_sym]
  end
  def self.all
    sites.values
  end
  def self.sites
    @sites ||= [:peter, :linus, :anacletus, :clemens].map { |s| [s, Site.new(subdomain: s)] }.to_h
  end
  def self.example(index = 0)
    sites.values[index]
  end
end

unless [].respond_to? :to_h
  class Array
    def to_h
      Hash[*flatten]
    end
  end
end
