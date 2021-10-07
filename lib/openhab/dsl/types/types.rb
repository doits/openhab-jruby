# frozen_string_literal: true

require_relative 'date_time_type'
require_relative 'decimal_type'
require_relative 'open_closed_type'
require_relative 'on_off_type'
require_relative 'percent_type'
require_relative 'primitive_type'
require_relative 'quantity_type'
require_relative 'string_type'
require_relative 'up_down_type'

module OpenHAB
  module DSL
    module Types
      # import all types that don't have a dedicated file
      java_import org.openhab.core.types.RefreshType,
                  org.openhab.core.types.UnDefType,
                  org.openhab.core.library.types.IncreaseDecreaseType,
                  org.openhab.core.library.types.NextPreviousType,
                  org.openhab.core.library.types.PlayPauseType,
                  org.openhab.core.library.types.StopMoveType,
                  org.openhab.core.library.types.RewindFastforwardType

      constants.each do |constant|
        klass = const_get(constant)

        next unless klass < java.lang.Enum

        # make sure == from PrimitiveType is inherited
        klass.remove_method(:==)

        # dynamically define predicate methods
        klass.values.each do |value| # rubocop:disable Style/HashEachMethods this isn't a Ruby hash
          # include all the aliases that we define for items both command and
          # state aliases (since types can be interrogated as an incoming
          # command, or as the state of an item)
          command = :"#{Items::COMMAND_ALIASES[value.to_s]}?"
          states = Items::PREDICATE_ALIASES[value.to_s]

          ([command] + states).uniq.each do |method|
            OpenHAB::Core.logger.trace("Defining #{klass}##{method} for #{value}")
            klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{method}
                self == #{value}
              end
            RUBY
          end
        end
      end
    end
  end
end
