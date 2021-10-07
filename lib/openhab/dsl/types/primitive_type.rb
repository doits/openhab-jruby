# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.types.PrimitiveType

      #
      # Monkey patch for DSL use
      #
      module PrimitiveType
        def inspect
          to_s # can't alias because to_s doesn't exist on PrimitiveType
        end

        def coerce(other)
          logger.trace("Coercing #{self} (#{self.class}) as a request from #{other.class}")
          return [other.as(self.class), self] if other.is_a?(PrimitiveType)

          raise TypeError, "can't convert #{other.class} into #{self.class}"
        end

        def eql?(other)
          return false unless other.instance_of?(self.class)

          equals(other)
        end

        def ==(other)
          return true if equal?(other)

          # i.e. ON == OFF
          return equals(other) if other.instance_of?(self.class)

          # i.e. ON == DimmerItem (also case statements)
          return self == other.raw_state if other.is_a?(Items::GenericItem)

          if other.respond_to?(:coerce)
            lhs, rhs = other.coerce(self)
            return lhs == rhs
          end

          super
        end
      end
    end
  end
end
