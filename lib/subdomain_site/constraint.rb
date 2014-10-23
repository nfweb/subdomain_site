class SubdomainSite::Constraint
  def initialize params={}
    @params = params || {}
  end
  def matches? request
    return false unless request.subdomain.present?

    site = SubdomainSite.site_model.find_by_subdomain(request.subdomain, params)
    site.present?
  end
end