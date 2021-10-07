# frozen_string_literal: true

require 'time'

require 'openhab/dsl/types/date_time_type'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.DateTimeItem

      #
      # Delegation to OpenHAB DateTime Item
      #
      class DateTimeItem
        include Comparable

        def ==(other)
          # need to check if we're referring to the same item before
          # fowarding to <=> (and thus checking equality with state)
          return true if equal?(other) || eql?(other)

          super
        end

        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          unless state?
            return 0 if other.nil?
            return 0 if other.is_a?(GenericItem) && raw_state == other.raw_state

            return nil
          end

          state <=> other
        end

        def coerce(other)
          logger.trace("Coercing #{self} as a request from  #{other.class}")
          return [other, nil] unless state?
          return [other, state] if other.is_a?(Types::DateTimeType) || other.respond_to?(:to_time)

          raise TypeError, "can't convert #{other.class} into #{self.class}"
        end

        # any method that exists on DateTimeType, Java's ZonedDateTime, or
        # Ruby's Time class gets forwarded to state (which will forward as
        # necessary)
        ((Types::DateTimeType.instance_methods +
          java.time.ZonedDateTime.instance_methods +
          Time.instance_methods) - instance_methods).each do |method|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method}(*args, &block)
              logger.trace("Forwarding #{method} from DateTimeItem to state \#{state} \#{state.class}: \#{state.method(:#{method})}:\#{state.method(:#{method}).source_location}")
              state&.#{method}(*args, &block)
            end
          RUBY
        end
      end
    end
  end
end
