module SubdomainSite
  module ActsAsSite
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_site(options = {})
        include SubdomainSite::ActsAsSite::LocalInstanceMethods

        options = { subdomain_attr: options } unless options.is_a?(Hash)
        options[:subdomain_attr] ||= :subdomain
        @subdomain_attr = options[:subdomain_attr].to_sym

        class_eval do
          require 'active_model'
          include ActiveModel::Validations

          validates @subdomain_attr, subdomain_attr_validations

          if constants.include?(:ActiveRecord) && include?(::ActiveRecord::Base)
            instance_eval "def #{@subdomain_attr}= (value); write_attribute(#{@subdomain_attr}, filter_subdomain_value(value)); end"
          end

          def find_by_subdomain(subdomain, params = {})
            subdomain.downcase!

            # TODO: enable some kind of caching

            find_by(params.merge(@subdomain_attr => subdomain))
          end
        end

        class_eval "def to_param; filter_subdomain_value(#{@subdomain_attr}); end"

        # There should usually only be one model representing subsites
        # but this automatic setting interferes with test suites.
        # SubdomainSite.site_model = self
      end

      def subdomain_attr_validations
        vals = { presence: true,
                 length: { in: SubdomainSite::SUBDOMAIN_LENGTH },
                 format: { with: SubdomainSite::SUBDOMAIN_PATTERN,
                           message: 'Subdomains must contain only alpha-numericals or hyphens but may neither begin nor end with a hyphen' }
               }
        vals[:uniqueness] = { case_sensitive: false } if respond_to? :validates_uniqueness_of
        vals
      end
    end

    module LocalInstanceMethods
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

      def filter_subdomain_value(val)
        val.to_s.downcase unless val.nil?
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
  end
end
