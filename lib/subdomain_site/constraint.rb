module SubdomainSite
  class Constraint
    def initialize(themodel = nil)
      @model = themodel || SubdomainSite.site_model
    end

    def matches?(request)
      request.subdomain.present? && find(request.subdomain)
    end

    private

    def find(subdomain)
      @model.find_subdomain_site(subdomain)
    end
  end
end
