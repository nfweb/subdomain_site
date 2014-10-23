require 'subdomain_site/acts_as_site_member'
class Post
  include ActiveModel::Model
  include SubdomainSite::ActsAsSiteMember

  attr_accessor :site, :title, :id
  acts_as_site_member

  def to_param
    id
  end
end
