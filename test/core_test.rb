require_relative 'test_helper'

class CoreTest < ActiveSupport::TestCase
  test 'site_for' do
    site = Site.new
    member = Post.new(site: site)
    assert_equal SubdomainSite.site_for(site), site
    assert_equal SubdomainSite.site_for(member), site

    mock = MiniTest::Mock.new
    mock.expect(:find_subdomain_site, site, [:site])
    old = SubdomainSite.site_model
    SubdomainSite.site_model = mock
    assert_equal SubdomainSite.site_for(:site), site
    mock.verify
    SubdomainSite.site_model = old
  end
end
