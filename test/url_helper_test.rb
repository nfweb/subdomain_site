require_relative 'test_helper'

class UrlHelperTest < ActionView::TestCase
  include SubdomainSite::UrlFor

  def domain
    'test.host'
  end

  def url(subdomain = nil, path = nil)
    subdomain = "#{subdomain}." if subdomain.present?
    "http://#{subdomain}#{domain}/#{path}"
  end

  def site
    @site ||= Site.example
  end

  def post
    @post ||= Post.new(site: site, title: 'Evengelii Gaudium', id: 1)
  end

  def different_site
    with_site(Site.example(1)) { yield }
  end

  def with_site(tmp_site = nil)
    SubdomainSite.with_site(tmp_site || site) { yield }
  end

  test 'site_url' do
    assert_equal url(site.subdomain), site_url(site)
  end

  test 'site_url_same_site' do
    with_site do
      assert_equal url(site.subdomain), site_url(site)
    end
  end

  test 'site_url_different_site' do
    different_site do
      assert_equal url(site.subdomain), site_url(site)
    end
  end

  test 'site_path' do
    assert_equal url(site.subdomain), site_path(site)
  end

  test 'site_path_same_site' do
    with_site do
      assert_equal '/', site_path(site)
    end
  end

  test 'site_path_other_site' do
    different_site do
      assert_equal url(site.subdomain), site_path(site)
    end
  end

  test 'member url' do
    assert_equal url(site.subdomain, "post/#{post.id}"), post_url(post)
  end

  test 'member url same site' do
    different_site do
      assert_equal url(site.subdomain, "post/#{post.id}"), post_url(post)
    end
  end

  test 'member url different site' do
    with_site do
      assert_equal url(site.subdomain, "post/#{post.id}"), post_url(post)
    end
  end

  test 'member path' do
    assert_equal url(site.subdomain, "post/#{post.id}"), post_path(post)
  end

  test 'member path same site' do
    with_site do
      assert_equal "/post/#{post.id}", post_path(post)
    end
  end

  test 'member path different site' do
    different_site do
      assert_equal url(site.subdomain, "post/#{post.id}"), post_path(post)
    end
  end
end
