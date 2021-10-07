# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.OnOffType

      #
      # Monkey patching OnOffType
      #
      class OnOffType
        #
        # Invert the type
        #
        # @return [Java::OrgOpenhabCoreLibraryTypes::OnOffType] OFF if ON, ON if OFF
        #
        def !
          return OFF if on?
          return ON if off?
        end
      end
    end
  end
end
