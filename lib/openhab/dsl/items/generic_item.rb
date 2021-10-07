# frozen_string_literal: true

require 'openhab/dsl/items/metadata'
require 'openhab/dsl/items/persistence'

module OpenHAB
  module DSL
    module Items
      java_import org.openhab.core.items.GenericItem

      class GenericItem
        include Log
        prepend Metadata
        prepend Persistence

        # rubocop:disable Naming/MethodName these mimic Java fields, which are
        # actually methods
        class << self
          def ACCEPTED_COMMAND_TYPES
            [org.openhab.core.types.RefreshType.java_class].freeze
          end

          def ACCEPTED_DATA_TYPES
            [org.openhab.core.types.UnDefType.java_class].freeze
          end
        end
        # rubocop:enable Naming/MethodName

        alias hash hash_code
        alias raw_state state
        remove_method(:==)

        #
        # Send a command to this item
        #
        # @param [Object] command to send to object
        #
        #
        def command(command)
          if command.is_a?(BigDecimal) || command.is_a?(Types::DecimalType)
            command = command.to_java.strip_trailing_zeros.to_plain_string
          end
          logger.trace "Sending Command #{command} to #{id}"
          org.openhab.core.model.script.actions.BusEvent.sendCommand(self, command.to_s)
        end
        alias << command

        #
        # Send an update to this item
        #
        # @param [Object] update the item
        #
        #
        def update(update)
          if update.is_a?(BigDecimal) || update.is_a?(Types::DecimalType)
            update = update.to_java.strip_trailing_zeros.to_plain_string
          end
          logger.trace "Sending Update #{update} to #{id}"
          org.openhab.core.model.script.actions.BusEvent.postUpdate(self, update.to_s)
        end

        #
        # Check if the item has a state (not UNDEF or NULL)
        #
        # @return [Boolean] True if state is not UNDEF or NULL
        #
        def state?
          !raw_state.is_a?(Types::UnDefType)
        end

        #
        # Get the item state
        #
        # @return [State] OpenHAB item state if state is not UNDEF or NULL, nil otherwise
        #
        def state
          raw_state if state?
        end

        #
        # Get an ID for the item, using the item label if set, otherwise item name
        #
        # @return [String] label if set otherwise name
        #
        def id
          label || name
        end

        #
        # Get the string representation of the state of the item
        #
        # @return [String] State of the item as a string
        #
        def to_s
          raw_state.to_s # call the super state to include UNDEF/NULL
        end

        #
        # Inspect the item
        #
        # @return [String] details of the item
        #
        def inspect
          to_string
        end

        #
        # Return all groups that this item is part of
        #
        # @return [Array<Group>] All groups that this item is part of
        #
        def groups
          group_names.map { |name| Groups.groups[name] }
        end

        def eql?(other)
          other.instance_of?(self.class) && hash == other.hash
        end

        #
        # Check for equality against supplied object
        #
        # @param [Object] other object to compare to
        #
        # @return [Boolean] True if other is a OnOffType and other equals state for this switch item,
        #   otherwise result from super
        #
        def ==(other)
          logger.trace("(#{self.class}) #{self} == #{other} (#{other.class})")
          logger.trace(caller)
          return true if equal?(other) || eql?(other)
          return true if !state? && other.nil?

          return raw_state == other.raw_state if other.is_a?(GenericItem)

          logger.trace("us #{state.class} them #{other.class}")
          logger.trace("#{state.method(:==)}:#{state.method(:==).source_location}")
          state == other
        end
      end
    end
  end
end
