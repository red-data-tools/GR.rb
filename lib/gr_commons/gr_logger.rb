# frozen_string_literal: true

# This script was created primarily for debugging purposes.
# Note: This script should be isolated.
# It should not be loaded when gr_commons/gr_commons is loaded.

require 'logger'
require 'pp'

module GRCommons
  # Convenience class methods

  class << self
    # Create a new GRLogger
    # @param out [String]
    # @return [GRLogger]
    # @example
    #   require 'gr_commons/gr_logger'
    #   GRCommons.gr_log("log.txt")

    def gr_log(out = $stderr)
      GRCommons::GRLogger.new(out)
    end

    # Return the last created GRLogger
    # @return [GRLogger]

    def gr_logger
      GRCommons::GRLogger.logger
    end
  end

  # If GR.rb call native functions of the GR framework, 
  # it will be recorded in the log file.
  #
  # @note Mainly used by developers for debugging.
  #
  # = How it works　
  # It prepend a module named Inspector to the singular class of the FFI module. 
  # It will inspects the GR function call of the FFI module
  #
  # @example
  #   require 'gr_commons/gr_logger'
  #   GRCommons::GRLogger.new("log.txt")

  class GRLogger < Logger
    # Return the last created GRLogger

    def self.logger
      @@logger ||= GRCommons::GRLogger.new
    end

    def initialize(out = $stderr)
      super(out, level: :info)
      @@logger ||= self
    end
  end
end

# GR

if Object.const_defined?(:GR)
  module GR
    module FFI
      module Inspector
        GR::FFI.ffi_methods.each do |s|
          define_method(s) do |*args|
            GRCommons.gr_logger.info "GR::FFI.#{s}\n#{args.pretty_inspect}\n"
            super(*args)
          end
        end
      end
      class << self
        prepend Inspector
      end
    end
  end
end

# GR3

if Object.const_defined?(:GR3)
  module GR3
    module FFI
      module Inspector
        GR3::FFI.ffi_methods.each do |s|
          define_method(s) do |*args|
            GRCommons.gr_logger.info "GR3::FFI.#{s}\n#{args.pretty_inspect}\n"
            super(*args)
          end
        end
      end
      class << self
        prepend Inspector
      end
    end
  end
end

# GRM

if Object.const_defined?(:GRM)
  module GRM
    module FFI
      module Inspector
        GRM::FFI.ffi_methods.each do |s|
          define_method(s) do |*args|
            GRCommons.gr_logger.info "GRM::FFI.#{s}\n#{args.pretty_inspect}\n"
            super(*args)
          end
        end
      end
      class << self
        prepend Inspector
      end
    end
  end
end
