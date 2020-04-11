# frozen_string_literal: true

module GR3
  # This module automatically converts Ruby arrays and Numo::Narray into
  # Fiddley::MemoryPointer.
  module GR3Base
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI,
                       prefix: 'gr3_',
                       default_type: :float)

    # Workaround for `gr_volume`
    # See https://github.com/sciapp/gr/issues/95
    define_ffi_methods(FFI,
                       prefix: 'gr_',
                       default_type: :double)
  end
  private_constant :GR3Base
end
