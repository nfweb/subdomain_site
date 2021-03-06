require_relative 'test_helper'

require 'subdomain_site/base'
require 'subdomain_site/acts_as_site'
require 'subdomain_site/acts_as_site_member'

class ActsAsSiteMemberTest < ActiveSupport::TestCase
  class Post
    include ActiveModel::Model
    include SubdomainSite::Base
    include SubdomainSite::ActsAsSiteMember
    attr_accessor :site, :id
    acts_as_site_member

    def initialize(site = nil, id = 1)
      super site: site, id: id
      send :set_site_from_environment # FIXME: should not be needed to call
    end

    def persisted?
      true
    end

    def to_param
      @id.to_s
    end
  end
  class PostWithoutDefaultSite
    include ActiveModel::Model
    include SubdomainSite::Base
    include SubdomainSite::ActsAsSiteMember
    attr_accessor :site, :id
    acts_as_site_member set_site_from_environment: false

    def initialize(site = nil, id = 1)
      super site: site, id: id
    end

    def persisted?
      true
    end

    def to_param
      @id.to_s
    end
  end

  class Site
    include ActiveModel::Model
    include SubdomainSite::Base
    include SubdomainSite::ActsAsSite
    attr_accessor :subdomain
    acts_as_site :subdomain
    def initialize(subdomain = nil)
      @subdomain = subdomain
    end

    def persisted?
      true
    end
  end

  def default_testing(post)
    assert post.site_member?
    refute post.site?
    assert_respond_to post, :site
  end

  def test_post_with_default_site
    post = Post.new
    default_testing(post)
    assert post.valid?, post.errors.inspect
    post.site = true
    assert_not post.valid?
    assert post.errors.include? :site
    post.site = Site.new
    assert post.valid?
  end

  def test_post_without_default_site
    post = PostWithoutDefaultSite.new
    default_testing(post)
    assert_not post.valid?
    assert post.errors.include? :site
    post.site = true
    assert_not post.valid?
    assert post.errors.include? :site
    post.site = Site.new
    assert post.valid?
  end

  def test_validation
  end

  class UrlTest < ActiveSupport::TestCase
    def acts_as_site_member_test_post_url(post, options = {})
      options[:site] = post.site
      options[:post] = post.to_param
      url_for(options)
    end

    def acts_as_site_member_test_post_path(post, options = {})
      options[:site] = post.site
      options[:post] = post.to_param
      url_for(options, nil, :path)
    end

    include SubdomainSite::Test::UrlForWrapper
    include ActionDispatch::Routing::PolymorphicRoutes

    def current_site
      @current_site ||= Site.new :peter
    end

    def other_site
      @other_site ||= Site.new :linus
    end

    def post_params_url(subdomain, url_strategy = :unknown)
      [{ post: @post.to_param, subdomain: subdomain }, url_strategy]
    end

    def test_url_different_site
      @post = Post.new(other_site)
      @actual = polymorphic_url(@post)
      assert_equal post_params_url('linus', :full), @actual
    end

    def test_path_different_site
      @post = Post.new(other_site)
      @actual = polymorphic_path(@post)
      assert_equal post_params_url('linus', :full), @actual
    end

    def test_url_same_site
      @post = Post.new(current_site)
      @actual = polymorphic_url(@post)
      assert_equal post_params_url('peter', :unknown), @actual
    end

    def test_path_same_site
      @post = Post.new(current_site)
      @actual = polymorphic_path(@post)
      assert_equal post_params_url('peter', :path), @actual
    end
  end
end
