# frozen_string_literal: true

module GR
  module GRBase
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI, 'gr_')
  end
  private_constant :GRBase

  extend GRCommons::GRCommonRule
end
