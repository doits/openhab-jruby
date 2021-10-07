# frozen_string_literal: true

module OpenHAB
  module DSL
    #
    # Patches OpenHAB types
    #
    module Types
      java_import org.openhab.core.library.types.OpenClosedType

      #
      # Monkey patch for DSL use
      #
      class OpenClosedType
        #
        # Invert the type
        #
        # @return [Java::OrgOpenhabCoreLibraryTypes::OpenClosedType] OPEN if CLOSED, CLOSED if OPEN
        #
        def !
          return OPEN if open?
          return CLOSED if closed?
        end

        #
        # Check if the supplied object is case equals to self
        #
        # @param [Object] other object to compare
        #
        # @return [Boolean] True if the other object is a ContactItem and has the same state
        #
        def ===(other)
          (open? && other.respond_to?(:open?) && other.open?) ||
            (closed? && other.respond_to?(:closed?) && other.closed?) ||
            super
        end

        #
        # Test for equality
        #
        # @param [Object] other Other object to compare against
        #
        # @return [Boolean] true if self and other can be considered equal, false otherwise
        #
        def ==(other)
          if other.respond_to?(:get_state_as)
            self == other.get_state_as(OpenClosedType)
          else
            super
          end
        end
      end
    end
  end
end
