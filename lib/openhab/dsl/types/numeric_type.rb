# frozen_string_literal: true

require 'bigdecimal'
require 'forwardable'

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      # methods common to DecimalType and QuantityType, but in a module
      # because the latter does not inherit from the former
      module NumericType
        def self.included(klass)
          klass.extend Forwardable

          klass.delegate %i[to_d zero?] => :to_big_decimal
          klass.delegate %i[positive? negative? to_f to_i to_int hash] => :to_d
          # remove the JRuby default == so that we can inherit the Ruby method
          klass.remove_method :==
        end

        #
        # Compare to another object
        #
        # @return [Boolean] if the same value is represented, without type
        #   conversion
        def eql?(other)
          return false unless other.instance_of?(self.class)

          compare_to(other).zero?
        end

        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 or nil depending on value supplied,
        #   nil comparison to supplied object is not possible.
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          if other.is_a?(self.class)
            logger.trace(caller)
            compare_to(other)
          elsif other.is_a?(Items::NumericItem) ||
                (other.is_a?(Items::GroupItem) && other.base_item.is_a?(NumericItem))
            return nil unless other.state?

            compare_to(other.state)
          elsif other.respond_to?(:to_d)
            to_d <=> other.to_d
          elsif other.respond_to?(:coerce)
            lhs, rhs = other.coerce(self)
            lhs <=> rhs
          end
        end

        def ==(other)
          # this is what Comparable does, which is overwritten by PrimitiveType
          # because DecimalType inherits from Comparable on the Java side
          r = self <=> other

          return false if r.nil?

          r.zero?
        end

        def +@
          self
        end
      end
    end
  end
end
