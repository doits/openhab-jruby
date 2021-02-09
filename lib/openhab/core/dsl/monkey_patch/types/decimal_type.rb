# frozen_string_literal: true

require 'java'

#
# MonkeyPatching Decimal Type
#
# rubocop:disable Style/ClassAndModuleChildren
class Java::OrgOpenhabCoreLibraryTypes::DecimalType
  # rubocop:enable Style/ClassAndModuleChildren

  #
  # Compare DecimalType to supplied object
  #
  # @param [Object] other object to compare to
  #
  # @return [Integer] -1,0,1 or nil depending on value supplied, nil comparison to supplied object is not possible.
  #
  def <=>(other)
    logger.trace("#{self.class} #{self} <=> #{other} (#{other.class})")
    case other
    when Numeric
      to_big_decimal.compare_to(other.to_d)
    when Java::OrgOpenhabCoreTypes::UnDefType
      1
    else
      other = other.state if other.respond_to? :state
      compare_to(other)
    end
  end

  #
  # Coerce objects into a DecimalType
  #
  # @param [Object] other object to coerce to a DecimalType if possible
  #
  # @return [Object] Numeric when applicable
  #
  def coerce(other)
    logger.trace("Coercing #{self} as a request from #{other.class}")
    case other
    when Numeric
      [other.to_d, to_big_decimal]
    else
      [other, self]
    end
  end

  #
  # Compare self to other through the spaceship operator
  #
  # @param [Object] other object to compare to
  #
  # @return [Boolean] True if equals
  #
  def ==(other)
    logger.trace("#{self.class} #{self} == #{other} (#{other.class})")
    (self <=> other).zero?
  end
end
