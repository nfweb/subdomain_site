require_relative 'test_helper'

class UrlForTest < ActiveSupport::TestCase
  include SubdomainSite::Test::UrlForWrapper

  def current_site
    :peter
  end

  def test_no_site
    @actual = url_for(foo: 'bar')
    assert_equal([{ foo: 'bar' }, :unknown], @actual)
  end

  def test_same_site_unknown
    @actual = url_for(foo: 'bar', site: :peter)
    assert_equal([{ foo: 'bar', subdomain: 'peter' }, :unknown], @actual)
  end

  def test_same_site_path
    @actual = url_for({ foo: 'bar', site: :peter }, nil, :path)
    assert_equal([{ foo: 'bar', subdomain: 'peter' }, :path], @actual)
  end

  def test_same_site_url
    @actual = url_for({ foo: 'bar', site: :peter }, nil, :full)
    assert_equal([{ foo: 'bar', subdomain: 'peter' }, :full], @actual)
  end

  def test_different_site
    @actual = url_for(foo: 'bar', site: :paul)
    assert_equal([{ foo: 'bar', subdomain: 'paul' }, :full], @actual)
  end

  def test_different_site_url
    @actual = url_for({ foo: 'bar', site: :paul }, nil, :path)
    assert_equal([{ foo: 'bar', subdomain: 'paul' }, :full], @actual)
  end

  def test_different_site_path
    @actual = url_for(foo: 'bar', site: :paul)
    assert_equal([{ foo: 'bar', subdomain: 'paul' }, :full], @actual)
  end

  def test_hash_immutable
    orig_params = { foo: 'bar', site: :linus }
    params = orig_params.dup.freeze
    url_for(params)
    assert_equal orig_params, params
  end
end
