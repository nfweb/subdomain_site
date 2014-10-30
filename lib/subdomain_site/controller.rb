module SubdomainSite
  module Controller
    def self.included(base)
      base.around_filter :with_site
      base.helper_method :current_site
    end

    def current_site
      SubdomainSite.site
    end

    private

    def with_site
      site = SubdomainSite.site_for(request.subdomain)
      site = SubdomainSite.default_fallback(site)
      SubdomainSite.with_site(site) { yield }
    end
  end
end
