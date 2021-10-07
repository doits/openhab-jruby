# frozen_string_literal: true

require 'openhab/dsl/lazy_array'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.items.GroupItem

      #
      # Delegation to OpenHAB Group Item
      #
      class GroupItem
        #
        # Class for indicating to triggers that a group trigger should be used
        #
        class GroupMembers
          include LazyArray

          attr_reader :group

          #
          # Create a new GroupMembers instance from a GroupItem
          #
          # @param [GroupItem] group_item GroupItem to use as trigger
          #
          def initialize(group_item)
            @group = group_item
          end

          # explicit conversion to array
          def to_a
            group.raw_members.to_a
          end
        end

        include Enumerable

        remove_method :==

        alias raw_members members
        #
        # Create a GroupMembers object for use in triggers
        #
        # @return [GroupMembers] A GroupMembers object
        #
        def members
          GroupMembers.new(self)
        end
        alias items members

        #
        # Iterates through the direct members of the Group
        #
        def each(&block)
          members.each(&block)
        end

        #
        # Get all members of the group recursively. Optionally filter the items to only return
        # Groups or regular Items
        #
        # @param [Symbol] filter Either :groups or :items
        #
        # @return [Array] An Array containing all descendants of the Group, optionally filtered
        #
        def all_members(filter = nil, &block)
          filter = nil if filter == :items
          raise ArgumentError, 'filter must be :groups or :items' unless [:groups, nil].include?(filter)

          if block
            get_members(&block).to_a
          elsif filter
            all_members.grep(GroupItem).to_a
          else
            all_members.to
          end
        end

        def <=>(other)
          logger.trace("(#{self.class}) #{self} <=> #{other} (#{other.class})")
          unless state?
            return true if other.nil?
            return true if other.is_a?(GenericItem) && !other.state?

            return nil
          end

          state <=> other
        end

        # delegate missing methods to the base item if possible
        def method_missing(method, *args, &block)
          logger.trace("Delegating #{method}(#{args.inspect}) to #{base_item.inspect}")
          logger.trace("#{args.length} args")
          logger.trace(block)
          return base_item.__send__(method, *args, &block) if base_item.respond_to?(method)

          super
        end

        def respond_to_missing?(method, include_private = false)
          return true if base_item.respond_to?(method)

          super
        end
      end
    end
  end
end
