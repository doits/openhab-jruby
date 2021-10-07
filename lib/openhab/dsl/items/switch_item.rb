# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB items
    #
    module Items
      java_import org.openhab.core.library.items.SwitchItem

      # Alias class names for easy is_a? comparisons
      ::Switch = SwitchItem

      #
      # Monkeypatching SwitchItem to add Ruby Support methods
      #
      class SwitchItem
        remove_method :==

        def truthy?
          on?
        end

        #
        # Send a command to invert the state of the switch
        #
        # @return [OnOffType] Inverted state
        #
        def toggle
          command(!self)
        end

        #
        # Return the inverted state of the switch: ON if the switch is OFF, UNDEF or NULL; OFF if the switch is ON
        #
        # @return [OnOffType] Inverted state
        #
        def !
          return !state if state?

          ON
        end
      end
    end
  end
end
