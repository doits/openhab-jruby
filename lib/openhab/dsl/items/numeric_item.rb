# frozen_string_literal: true

require 'forwardable'

module OpenHAB
  module DSL
    module Items
      #
      # Delegation to OpenHAB Number Item
      #
      module NumericItem
        include Comparable

        def self.included(klass)
          klass.extend Forwardable
          # none of these do nil checking, but neither did the old code
          klass.delegate %i[+ - * / | positive? negative? to_d to_f to_int zero?] => :state
          # remove the JRuby default == so that we can inherit the Ruby method
          klass.remove_method :==
        end

        #
        # Check if NumericItem is truthy? as per defined by library
        #
        # @return [Boolean] True if item is not in state UNDEF or NULL and value is not zero.
        #
        def truthy?
          state && !state.zero?
        end

        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          unless state?
            return true if other.nil?
            return true if other.is_a?(GenericItem) && !other.state?

            return nil
          end

          state <=> other
        end

        def coerce(other)
          logger.trace("Coercing #{self} as a request from  #{other.class}")
          return [other, nil] unless state?
          return [other, state] if other.is_a?(Types::NumericType) || other.respond_to?(:to_d)

          raise TypeError, "can't convert #{other.class} into #{self.class}"
        end
      end
    end
  end
end
