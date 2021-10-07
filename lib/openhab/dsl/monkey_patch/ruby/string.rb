# frozen_string_literal: true

require 'openhab/dsl/items/numeric_item'
require 'openhab/dsl/items/date_time_item'
require 'openhab/dsl/types/date_time_type'
require 'openhab/dsl/types/quantity_type'

module OpenHAB
  module DSL
    module MonkeyPatch
      module Ruby
        #
        # Extend String class
        #
        module StringExtensions
          # Compares String to another object
          #
          # @param [Object] other object to compare to
          #
          # @return [Boolean]  true if the two objects contain the same value, false otherwise
          #
          def ==(other)
            case other
            when Types::QuantityType,
              Types::DateTimeType,
              Items::DateTimeItem,
              Items::NumericItem
              other == self
            else
              super
            end
          end

          def <=>(other)
            case other
            when Types::QuantityType,
              Types::DateTimeType,
              Items::DateTimeItem,
              Items::NumericItem
              (other <=> self)&.-@()
            else
              super
            end
          end
        end
      end
    end
  end
end

String.prepend(OpenHAB::DSL::MonkeyPatch::Ruby::StringExtensions)
