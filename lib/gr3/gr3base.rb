# frozen_string_literal: true

module GR3
  module GR3Base
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI,
                       prefix: 'gr3_',
                       default_type: :float)

    def self.check_error
      line = ::FFI::MemoryPointer.new(:int)
      file = ::FFI::MemoryPointer.new(:string, 100)
      e = FFI.gr3_geterror(1, line, file)
      if e != 0
        mesg = FFI.gr3_geterrorstring(e)
        raise "GR3 error #{file} #{line} #{mesg}"
      end
    end
  end
  private_constant :GR3Base

  extend GRCommons::GRCommonUtils
end
