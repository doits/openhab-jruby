# frozen_string_literal: true

require_relative 'numeric_type'

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.QuantityType

      #
      # MonkeyPatching QuantityType
      #
      class QuantityType
        include NumericType

        #
        # Convert this quantity into a another unit
        #
        # @param [Object] other String or Unit to convert to
        #
        # @return [QuantityType] This quantity converted to another unit
        #
        def |(other)
          other = org.openhab.core.types.util.UnitUtils.parse_unit(other) if other.is_a?(String)

          to_unit(other)
        end

        def <=>(other)
          other = self.class.new(other) if other.is_a?(String)
          super(other)
        end

        #
        # Coerce objects into a QuantityType
        #
        # @param [Object] other object to coerce to a QuantityType if possible
        #
        # @return [Object] Numeric when applicable
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(Items::NumericItem) ||
             (other.is_a?(Items::GroupItem) && other.base_item.is_a?(Items::NumericItem))
            raise TypeError, "can't convert #{UnDefType} into #{self.class}" unless other.state?

            [other.state, self]
          elsif other.is_a?(PrimitiveType)
            [other, as(other.class)]
          elsif other.respond_to?(:to_d)
            # assume the same units as this object
            [QuantityType.new(other.to_d.to_java, unit), self]
          elsif other.is_a?(String)
            [QuantityType.new(other), self]
          else
            raise TypeError, "can't convert #{other.class} into #{self.class}"
          end
        end

        # arithmetic operators
        alias -@ negate

        DIMENSIONLESS_NON_UNITIZED_OPERATIONS = %i[* /].freeze
        private_constant :DIMENSIONLESS_NON_UNITIZED_OPERATIONS

        {
          :add => :+,
          :subtract => :-,
          :multiply => :*,
          :divide => :/
        }.each do |java_op, ruby_op|
          convert = if DIMENSIONLESS_NON_UNITIZED_OPERATIONS.include?(ruby_op)
                      ->(other) { other }
                    else
                      ->(other) { "self.class.new(#{other}, unit)" }
                    end

          #
          # Perform addition
          #
          # @return [QuantityType] result as a QuantityType
          #
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{ruby_op}(other)
              if other.is_a?(Items::NumericItem) ||
                (other.is_a?(Items::GroupItem) && other.base_item.is_a?(Items::NumericItem))
                self #{ruby_op} other.state
              elsif other.is_a?(QuantityType)
                #{java_op}(other)
              elsif other.is_a?(DecimalType)
                #{java_op}(#{convert.call('other.to_big_decimal')})
              elsif other.is_a?(Java::JavaMath::BigDecimal)
                #{java_op}(#{convert.call('other')})
              elsif other.respond_to?(:to_d)
                #{java_op}(#{convert.call('other.to_d.to_java')})
              elsif other.is_a?(String)
                #{java_op}(self.class.new(other))
              elsif other.respond_to?(:coerce)
                lhs, rhs = other.coerce(to_d)
                lhs #{ruby_op} rhs
              else
                raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
              end
            end
          RUBY
        end

        # back-compat alias
        Quantity = QuantityType
      end
    end
  end
end
