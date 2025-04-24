# frozen_string_literal: true

# Load all available versions
require "glare/ux_metrics/desirability/v1"
require "glare/ux_metrics/desirability/v2"  # Uncomment when version 2 is available

module Glare
  module UxMetrics
    module Desirability
      # Define the default Parser by assigning the constant
      Parser = V2::Parser # <--- This is the key line

      # You could also add helper methods if needed
      def self.default_parser_version
        Parser
      end
    end
  end
end

