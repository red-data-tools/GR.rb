# frozen_string_literal: true

module GR
  module GRBase
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI,
                       prefix: 'gr_',
                       default_type: :double)
  end
  private_constant :GRBase

  extend GRCommons::GRCommonUtils
end
