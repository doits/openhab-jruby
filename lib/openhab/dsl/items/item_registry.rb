# frozen_string_literal: true

require 'singleton'

require 'openhab/core/entity_lookup'
require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
    #
    # Manages OpenHAB items
    #
    module Items
      #
      # Delegates to underlying set of all OpenHAB Items, provides convenience methods
      #
      class ItemRegistry
        include LazyArray
        include Singleton

        # Fetches the named item from the the ItemRegistry
        # @param [String] name
        # @return Item from registry, nil if item missing or requested item is a Group Type
        def [](name)
          OpenHAB::Core::EntityLookup.lookup_item(name)
        rescue Java::OrgOpenhabCoreItems::ItemNotFoundException
          nil
        end

        # Returns true if the given item name exists
        # @param name [String] Item name to check
        # @return [Boolean] true if the item exists, false otherwise
        def include?(name)
          !$ir.getItems(name).empty? # rubocop: disable Style/GlobalVars
        end
        alias key? []

        # explicit conversion to array
        def to_a
          $ir.items.grep_v(org.openhab.core.items.GroupItem) # rubocop:disable Style/GlobalVars
        end
      end

      # Fetches all non-group items from the item registry
      # @return [OpenHAB::DSL::Items::Items]
      def items
        ItemRegistry.instance
      end
    end
  end
end
