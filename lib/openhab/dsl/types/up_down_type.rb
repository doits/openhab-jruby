# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.UpDownType

      #
      # MonkeyPatching UpDownType
      #
      class UpDownType
        #
        # Invert the type
        #
        # @return [Java::OrgOpenhabCoreLibraryTypes::UpDownType] UP if DOWN, DOWN if UP
        #
        def !
          return UP if down?
          return DOWN if up?
        end
      end
    end
  end
end
