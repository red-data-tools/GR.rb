# frozen_string_literal: true

module GR3
  # This module automatically converts Ruby arrays and Numo::Narray into pointers.
  module GR3Base
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI,
                       prefix: 'gr3_',
                       default_type: :float)
    # workaround for `gr_volume`
    define_ffi_methods(FFI,
                       prefix: 'gr_',
                       default_type: :double)
  end
  private_constant :GR3Base

  extend GRCommons::GRCommonUtils
end
