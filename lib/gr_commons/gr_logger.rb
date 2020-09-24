# frozen_string_literal: true

# This file was created primarily for debugging purposes.
# The file should be isolated. 
# it will not be loaded when gr_commons/gr_commons is loaded.

require 'logger'
require 'rainbow'
require 'awesome_print'

module GRCommons
  class << self
    def gr_log(out)
      GRCommons::GRLogger.new(out)
    end
    def gr_logger
      GRCommons::GRLogger.logger
    end
  end

  class GRLogger < Logger
    def self.logger
      @@logger ||= GRCommons::GRLogger.new
    end

    def initialize(out = STDERR)
      super(out, level: :info)
      @@logger ||= self
    end
  end
end

if Object.const_defined?(:GR)
  module GR
    module FFI
      module Inspector
        GR::FFI.ffi_methods.each do |i|
          define_method(i) do |*args|
            GRCommons.gr_logger.info "GR::FFI.#{i}\n" + args.ai  + "\n"
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

if Object.const_defined?(:GR3)
  module GR3
    module FFI
      module Inspector
        GR3::FFI.ffi_methods.each do |i|
          define_method(i) do |*args|
            GRCommons.gr_logger.info "GR3::FFI.#{i}\n" + args.ai  + "\n"
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

if Object.const_defined?(:GRM)
  module GRM
    module FFI
      module Inspector
        GRM::FFI.ffi_methods.each do |i|
          define_method(i) do |*args|
            GRCommons.gr_logger.info "GRM::FFI.#{i}\n" + args.ai  + "\n"
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
