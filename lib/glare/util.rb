# frozen_string_literal: true

module Glare
  class Util
    def self.str_is_integer?(str)
      [                          # In descending order of likeliness:
        /^[-+]?[1-9]([0-9]*)?$/, # decimal
        /^0[0-7]+$/,             # octal
        /^0x[0-9A-Fa-f]+$/,      # hexadecimal
        /^0b[01]+$/              # binary
      ].each do |match_pattern|
        return true if str =~ match_pattern
      end
      false
    end
  end
end
