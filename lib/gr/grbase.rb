# frozen_string_literal: true

module GR
  # This module automatically converts Ruby arrays and Numo::Narray into
  # Fiddley::MemoryPointer.
  module GRBase
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI,
                       prefix: 'gr_',
                       default_type: :double)
  end
  private_constant :GRBase
end
