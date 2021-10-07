# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.PercentType

      #
      # MonkeyPatching PercentType
      #
      class PercentType
        # remove the JRuby default == so that we can inherit the Ruby method
        remove_method :==

        #
        # Check if the state is ON
        #
        # @return [Boolean] true if ON, false otherwise
        #
        def on?
          as(OnOffType).on?
        end

        #
        # Check if the state is OFF
        #
        # @return [Boolean] true if OFF, false otherwise
        #
        def off?
          as(OnOffType).off?
        end

        #
        # Check if the state is UP
        #
        # @return [Boolean] true if UP, false otherwise
        #
        def up?
          !!as(UpDownType)&.up?
        end

        #
        # Check if the state is DOWN
        #
        # @return [Boolean] true if DOWN, false otherwise
        #
        def down?
          !!as(UpDownType)&.down?
        end
      end
    end
  end
end
