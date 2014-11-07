# ActiveModel Rails module.
module ActiveModel
  # ActiveModel::Validations Rails module. Contains all the default validators.
  module Validations
    class SiteValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors[attribute] << (options[:message] || 'is not a valid site object') unless
            value.respond_to?(:site?) && value.site?
      end
    end
  end
end
