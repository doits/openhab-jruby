# frozen_string_literal: true

require 'openhab/dsl/items/numeric_item'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.RollershutterItem

      #
      # Delegator to OpenHAB Rollershutter Item
      #
      class RollershutterItem
        include NumericItem

        alias position state
      end
    end
  end
end
