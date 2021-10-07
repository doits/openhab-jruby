# frozen_string_literal: true

require 'openhab/dsl/items/numeric_item'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.library.items.NumberItem

      #
      # Delegation to OpenHAB Number Item
      #
      class NumberItem
        include NumericItem
      end
    end
  end
end
