# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB items
    #
    module Items
      java_import org.openhab.core.library.items.DimmerItem

      #
      # Alias class for is_a? testing
      #
      ::Dimmer = DimmerItem

      #
      # Monkey Patch DimmerItem
      #
      class DimmerItem
        include NumericItem

        #
        # Dim the dimmer
        #
        # @param [Integer] amount to dim by
        #
        # @return [Integer] level target for dimmer
        #
        def dim(amount = 1)
          command([state&.-(amount), 0].compact.max)
        end

        #
        # Brighten the dimmer
        #
        # @param [Integer] amount to brighten by
        #
        # @return [Integer] level target for dimmer
        #
        def brighten(amount = 1)
          command([state&.+(amount), 100].compact.min)
        end
      end
    end
  end
end
