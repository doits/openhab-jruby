# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB items
    #
    module Items
      java_import org.openhab.core.library.items.ContactItem

      #
      # Alias class for ContactItem
      #
      ::Contact = ContactItem

      #
      # Monkey patch Contact Item with Ruby methods
      #
      class ContactItem
        #
        # Return the inverted state of the contact: CLOSED if the contact is
        # OPEN, UNDEF or NULL; OPEN if the contact is CLOSED
        #
        # @return [OpenClosedType] Inverted state
        #
        def !
          return !state if state?

          CLOSED
        end
      end
    end
  end
end
