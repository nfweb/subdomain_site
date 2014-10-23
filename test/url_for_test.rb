require_relative "test_helper"

class UrlForTest < ActiveSupport::TestCase
  module UrlFor
    def url_for(*args)
      args
    end
  end

  include UrlFor
  include SubdomainSite::UrlFor

  def current_site
    :peter
  end

  def test_no_site
    @actual = url_for(foo: 'bar')
    assert_equal [{foo: 'bar'}], @actual
  end

  def test_same_site
    @actual = url_for(foo: 'bar', site: :peter)
    assert_equal [{foo: 'bar', subdomain: 'peter', only_path: false}], @actual
  end
  def test_same_site_path
    @actual = url_for(foo: 'bar', site: :peter, only_path: true)
    assert_equal [{foo: 'bar', subdomain: 'peter', only_path: true}], @actual
  end
  def test_same_site_url
    @actual = url_for(foo: 'bar', site: :peter, only_path: false)
    assert_equal [{foo: 'bar', subdomain: 'peter', only_path: false}], @actual
  end

  def test_different_site
    @actual = url_for(foo: 'bar', site: :paul)
    assert_equal [{foo: 'bar', subdomain: 'paul', only_path: false}], @actual
  end
  def test_different_site_url
    @actual = url_for(foo: 'bar', site: :paul, only_path: true)
    assert_equal [{foo: 'bar', subdomain: 'paul', only_path: false}], @actual
  end
  def test_different_site_path
    @actual = url_for(foo: 'bar', site: :paul, only_path: false)
    assert_equal [{foo: 'bar', subdomain: 'paul', only_path: false}], @actual
  end

  def test_hash_immutable
    orig_params = { foo: 'bar', site: :linus }
    params = orig_params.dup.freeze
    url_for(params)
    assert_equal orig_params, params
  end
end
