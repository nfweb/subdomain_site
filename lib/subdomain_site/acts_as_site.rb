module SubdomainSite
  module ActsAsSite
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_site(options = {})
        include SubdomainSite::ActsAsSite::LocalInstanceMethods

        options = { subdomain_attr: options } unless options.is_a?(Hash)
        options[:subdomain_attr] ||= :subdomain

        cattr_accessor :subdomain_attr
        self.subdomain_attr = options[:subdomain_attr].to_sym

        require 'active_model'
        include ActiveModel::Validations
        include ActiveModel::Validations::Callbacks

        validates subdomain_attr, subdomain_attr_validations
        before_validation :downcase_subdomain

        # There should usually only be one model representing subsites
        # but this automatic setting interferes with test suites.
        # SubdomainSite.site_model = self
      end

      def subdomain_attr_validations
        vals = { exclusion: { in: [nil] },
                 length: { in: SubdomainSite::SUBDOMAIN_LENGTH },
                 format: { with: SubdomainSite::SUBDOMAIN_PATTERN,
                           message: 'Subdomains must contain only alpha-numericals or ' \
                                    'hyphens but may neither begin nor end with a hyphen' }
               }
        vals[:uniqueness] = { case_sensitive: false } if respond_to? :validates_uniqueness_of
        vals
      end

      def find_subdomain_site(subdomain)
        @subdomain_cache ||= {}
        @subdomain_cache[subdomain] ||= find_by(subdomain_attr => filter_subdomain_value(subdomain))
      end

      def filter_subdomain_value(val)
        val.to_s.strip.downcase unless val.nil?
      end
    end

    module LocalInstanceMethods
      delegate :filter_subdomain_value, to: 'self.class'

      def site
        self
      end

      def site?
        true
      end

      def site_member?
        true
      end

      def default_url_options
        { subdomain: to_param }
      end

      def downcase_subdomain
        send "#{self.class.subdomain_attr}=", filter_subdomain_value(send "#{self.class.subdomain_attr}")
      end

      def to_param
        filter_subdomain_value send self.class.subdomain_attr
      end
    end
  end

  class DefaultSite
    require 'active_model'
    include ActiveModel::Model
    include SubdomainSite::ActsAsSite

    def persisted?
      true
    end

    def readonly?
      true
    end

    def subdomain
      SubdomainSite.default_subdomain
    end

    def site?
      true
    end

    def site
      self
    end
  end
end
