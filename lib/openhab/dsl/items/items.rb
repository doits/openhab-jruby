# frozen_string_literal: true

require 'openhab/dsl/monkey_patch/events/item_command'

require_relative 'item_registry'

require_relative 'contact_item'
require_relative 'date_time_item'
require_relative 'dimmer_item'
require_relative 'generic_item'
require_relative 'group_item'
require_relative 'image_item'
require_relative 'number_item'
require_relative 'player_item'
require_relative 'rollershutter_item'
require_relative 'string_item'
require_relative 'switch_item'

module OpenHAB
  module DSL
    module Items
      PREDICATE_ALIASES = Hash.new { |_h, k| [:"#{k.downcase}?"] }
                              .merge({
                                       'PLAY' => [:playing?],
                                       'PAUSE' => [:paused?],
                                       'REWIND' => [:rewinding?],
                                       'FASTFORWARD' => %i[fastforwarding? fast_forwarding?]
                                     }).freeze

      COMMAND_ALIASES = Hash.new { |_h, k| k.downcase.to_sym }
                            .merge({
                                     'FASTFORWARD' => :fast_forward
                                   }).freeze

      OpenHAB::Core.logger.trace(constants)
      # sort classes by hierarchy so we define methods on parent classes first
      constants.map { |c| const_get(c) }
               .grep(Module)
               .select { |k| k <= GenericItem && k != GroupItem }
               .sort { |a, b| a < b ? -1 : 1 }
               .reverse_each do |klass|
        OpenHAB::Core.logger.trace(klass.to_s)

        klass.field_reader :ACCEPTED_COMMAND_TYPES, :ACCEPTED_DATA_TYPES unless klass == GenericItem

        # dynamically define command and state methods
        klass.ACCEPTED_DATA_TYPES
             .map(&:ruby_class)
             .select { |k| k < java.lang.Enum }
             .flat_map(&:values).each do |state|
          PREDICATE_ALIASES[state.to_s].each do |predicate|
            next if klass.instance_methods.include?(predicate)

            OpenHAB::Core.logger.trace("Defining #{klass}##{predicate} for #{state}")
            klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
              def #{predicate}
                self.raw_state == #{state}
              end
            RUBY
          end
        end

        klass.ACCEPTED_COMMAND_TYPES
             .map(&:ruby_class)
             .select { |k| k < java.lang.Enum }
             .flat_map(&:values).each do |value|
          command = COMMAND_ALIASES[value.to_s]
          next if klass.instance_methods.include?(command)

          OpenHAB::Core.logger.trace("Defining #{klass}##{command} for #{value}")
          klass.class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{command}
              command(#{value})
            end
          RUBY

          OpenHAB::Core.logger.trace("Defining ItemCommandEvent##{command}? for #{value}")
          MonkeyPatch::Events::ItemCommandEvent.class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{command}?
              command == #{value}
            end
          RUBY
        end
      end
    end
  end
end
