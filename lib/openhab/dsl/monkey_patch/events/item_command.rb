# frozen_string_literal: true

module OpenHAB
  module DSL
    module MonkeyPatch
      #
      # Patches OpenHAB events
      #
      module Events
        java_import org.openhab.core.items.events.ItemCommandEvent

        #
        # Monkey patch with ruby style accesors
        #
        class ItemCommandEvent
          alias command item_command
        end
      end
    end
  end
end
