# frozen_string_literal: true

module GRM
  # This module automatically converts Ruby arrays and Numo::Narray into
  # Fiddley::MemoryPointer.
  module GRMBase
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI,
                       prefix: 'grm_',
                       default_type: :float) # FIXME!
  end
  private_constant :GRMBase
end
