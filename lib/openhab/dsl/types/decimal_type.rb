# frozen_string_literal: true

require_relative 'numeric_type'

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.DecimalType

      #
      # MonkeyPatching Decimal Type
      #
      class DecimalType
        include NumericType

        delegate :to_java => :to_d

        def initialize(value = nil, *args)
          if value.nil? && args.empty?
            super()
            return
          end

          if value.is_a?(Java::JavaMath::BigDecimal)
            super
          elsif value.is_a?(BigDecimal)
            super(value.to_java, *args)
          elsif value.is_a?(Items::NumericItem) ||
                (value.is_a?(Items::GroupItem) && value.base_item.is_a?(Items::NumericItem))
            super(value.state, *args)
          elsif value.respond_to?(:to_d)
            super(value.to_d.to_java, *args)
          else # rubocop:disable Lint/DuplicateBranch
            # duplicates the Java BigDecimal branch, but that needs to go first
            # in order to avoid unnecessary conversions
            super
          end
        end

        def is_a?(klass)
          return true if klass == Numeric

          super
        end

        #
        # Convert DecimalType to a QuantityType
        #
        # @param [Object] other String or Unit representing an OpenHAB Unit
        #
        # @return [OpenHAB::Core::DSL::Types::QuantityType] DecimalType converted to supplied Unit
        #
        def |(other)
          other = org.openhab.core.types.util.UnitUtils.parse_unit(other) if other.is_a?(String)
          QuantityType.new(to_big_decimal, other)
        end

        # Coerce objects into a DecimalType
        #
        # @param [Object] other object to coerce to a DecimalType if possible
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
            [DecimalType.new(other.to_d), self]
          else
            raise TypeError, "can't convert #{other.class} into #{self.class}"
          end
        end

        # arithmetic operators
        def -@
          self.class.new(to_big_decimal.negate)
        end

        {
          :add => :+,
          :subtract => :-,
          :multiply => :*,
          :divide => :/,
          :remainder => :%,
          :pow => :**
        }.each do |java_op, ruby_op|
          class_eval(
            # def +(other)
            #   if other.is_a?(DecimalType)
            #     self.class.new(to_big_decimal.add(other.to_big_decimal))
            #   elsif other.is_a?(Java::JavaMath::BigDecimal)
            #     self.class.new(to_big_decimal.add(other))
            #   elsif other.is_a?(Numeric)
            #     self.class.new((to_d + other).to_java)
            #   elsif other.respond_to?(:coerce)
            #     lhs, rhs = other.coerce(to_d)
            #     lhs + rhs
            #   else
            #     raise TypeError, "#{other.class} can't be coerced into DecimalType"
            #   end
            # end
            <<~RUBY, __FILE__, __LINE__ + 1
              def #{ruby_op}(other)
                if other.is_a?(DecimalType)
                  self.class.new(to_big_decimal.#{java_op}(other.to_big_decimal))
                elsif other.is_a?(Java::JavaMath::BigDecimal)
                  self.class.new(to_big_decimal.#{java_op}(other))
                elsif other.respond_to?(:to_d)
                  self.class.new(to_d #{ruby_op} other)
                elsif other.respond_to?(:coerce)
                  lhs, rhs = other.coerce(to_d)
                  lhs #{ruby_op} rhs
                else
                  raise TypeError, "\#{other.class} can't be coerced into \#{self.class}"
                end
              end
            RUBY
          )

          # any method that exists on BigDecimal gets forwarded to to_d
          (BigDecimal.instance_methods - instance_methods).each do |method|
            class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}(*args, &block)
                logger.trace("Forwarding #{method} from DecimalType to to_d")
                to_d.#{method}(*args, &block)
              end
            RUBY
          end
        end
      end
    end
  end
end
