class SitesController < ActionController::Base
  def index
    @sites = Site.all
  end
  def show
    @site = current_site
  end
end