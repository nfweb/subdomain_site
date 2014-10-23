module SubdomainSite
  class << self
    attr_accessor :default_site
    attr_reader :site_model
  end

  def self.default_fallback(site)
    if site_available?(site)
      site
    else
      default_site
    end
  end
  def self.site_model=(site_model)
    site_model = site_model.to_s.classify.constantize unless site_model.is_a?(Class) or site_model.nil?
    @site_model = site_model
  end
  def self.subdomain_for(site)
    site = site.subdomain if site.respond_to? :subdomain
    site.to_s
  end
  def self.site_for(subdomain)
    site_model.find_by_subdomain(subdomain)
  end
  def self.site_available?(site)
    site.present?
  end

  # Gets current site
  def self.site
    Thread.current[:subdomain_site] ||= SubdomainSite.default_site
  end
  # Sets current site
  def self.site=(value)
    Thread.current[:subdomain_site] = value
  end

  def self.with_site(tmp_site = nil)
    if tmp_site
      current_site = self.site
      self.site    = tmp_site
    end
    yield
  ensure
    self.site = current_site if tmp_site
  end
end
