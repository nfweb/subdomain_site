module SubdomainSite
  class Constraint
    def matches?(request)
      request.subdomain.present? && SubdomainSite.site_model.find_by_subdomain(request.subdomain)
    end
  end
end
