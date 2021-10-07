# frozen_string_literal: true

require 'time'

# force to_s to be ISO8601 format
Time.alias_method(:to_s, :iso8601)
