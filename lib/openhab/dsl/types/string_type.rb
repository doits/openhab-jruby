# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.StringType

      #
      # MonkeyPatching StringType Type
      #
      class StringType
        include Comparable

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
          if other.respond_to?(:to_str)
            to_s <=> other.to_str
          elsif other.respond_to?(:coerce)
            lhs, rhs = other.coerce(self)
            lhs <=> rhs
          end
        end

        def ==(other)
          # this is what Comparable does, which is overwritten by PrimitiveType
          # because StringType inherits from Comparable on the Java side
          r = self <=> other

          return false if r.nil?

          r.zero?
        end

        # Coerce objects into a DateTimeType
        #
        # @param [Object] other object to coerce to a DecimalType if possible
        #
        # @return [Object] Numeric when applicable
        #
        def coerce(other)
          logger.trace("Coercing #{self} as a request from #{other.class}")
          if other.is_a?(Items::StringItem)
            raise TypeError, "can't convert #{other.raw_state} into #{self.class}" unless other.state?

            [other.state, self]
          elsif other.respond_to?(:to_str)
            [String.new(other.to_str), self]
          else
            raise TypeError, "can't convert #{other.class} into #{self.class}"
          end
        end

        # any method that exists on String gets forwarded to to_s
        (String.instance_methods - instance_methods).each do |method|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method}(*args, &block)
              logger.trace("Forwarding #{method} from StringType to to_s")
              to_s.#{method}(*args, &block)
            end
          RUBY
        end
      end
    end
  end
end
