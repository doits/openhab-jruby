# frozen_string_literal: true

module OpenHAB
  module DSL
    module Items
      #
      # Delegator to OpenHAB String Item
      #
      class StringItem
        include Comparable

        # @return [Regex] Regular expression matching blank strings
        BLANK_RE = /\A[[:space:]]*\z/.freeze
        private_constant :BLANK_RE

        #
        # Detect if the string is blank (not set or only whitespace)
        #
        # @return [Boolean] True if string item is not set or contains only whitespace, false otherwise
        #
        def blank?
          return true unless state?

          state.empty? || BLANK_RE.match?(self)
        end

        #
        # Check if StringItem is truthy? as per defined by library
        #
        # @return [Boolean] True if item is not in state UNDEF or NULL and value is not blank
        #
        def truthy?
          state? && !blank?
        end

        # any method that exists on String gets forwarded to state (which will forward as
        # necessary)
        (String.instance_methods - instance_methods).each do |method|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{method}(*args, &block)
              logger.trace("Forwarding #{method} from StringItem to state \#{state} \#{state.class}: \#{state.method(:#{method})}:\#{state.method(:#{method}).source_location}")
              state&.#{method}(*args, &block)
            end
          RUBY
        end

        #
        # Compare StringItem to supplied object
        #
        # @param [Object] other object to compare to
        #
        # @return [Integer] -1,0,1 or nil depending on value supplied,
        #   nil comparison to supplied object is not possible.
        #
        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          unless state?
            return true if other.nil?
            return true if other.is_a?(GenericItem) && !other.state?

            return nil
          end

          state <=> other
        end
      end
    end
  end
end
