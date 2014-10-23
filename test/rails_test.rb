# encoding: UTF-8
require_relative 'test_helper'

class SitesControllerTest < ActionController::TestCase
  setup do
    @controller = SitesController.new
  end

  def domain
    'example.com'
  end

  test 'get index' do
    @request.host = domain
    get 'index'
    assert_response :success
    assert_not_nil assigns(:sites)
    links = css_select('ul li a')
    urls = Site.sites.map { | _k, s | "http://#{s.subdomain}.#{domain}/" }
    links.each do | a |
      assert_includes urls, a['href']
    end
  end

  test 'get site' do
    site = Site.example
    @request.host = "#{site.subdomain}.#{domain}"
    get :show

    assert_response :success
    assert_equal site, assigns(:site)
    assert_equal site.subdomain.to_s, css_select('h1').first.children.first.content
  end

  test 'get undefined site' do
    @request.host = "udefined.#{domain}"
    get :show
  end
end
