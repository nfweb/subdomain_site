module SubdomainSite
  SUBDOMAIN_LENGTH = 1..63
  SUBDOMAIN_PATTERN = /\A[a-z0-9](?:[a-z0-9\-]{0,61}[a-z0-9])?\z/i

  # Internal implementations of ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper
  # have changed in Rails 4.2, so we need to distinguish versions in several places.
  RAILS42 = Rails.gem_version >= Gem::Version.new('4.2.0beta1')

  class << self
    attr_accessor :default_subdomain
    attr_reader :site_model
    attr_writer :default_site

    def default_fallback(site)
      if site_available?(site)
        site
      else
        default_site
      end
    end

    def site_model=(site_model)
      site_model = site_model.to_s.classify.constantize unless site_model.is_a?(Class) || site_model.nil?
      @site_model = site_model
    end

    def site_for(subdomain)
      site_model.find_by_subdomain(subdomain)
    end

    def site_available?(site)
      site.present?
    end

    def default_site
      @default_site = @default_site.call if @default_site.respond_to? :call
      @default_site
    end

    # Gets current site
    def site
      Thread.current[:subdomain_site] ||= default_site
    end
    # Sets current site
    def site=(value)
      Thread.current[:subdomain_site] = value
    end

    def with_site(tmp_site = nil)
      if tmp_site
        current_site = site
        self.site    = tmp_site
      end
      yield
    ensure
      self.site = current_site if tmp_site
    end
  end
end
