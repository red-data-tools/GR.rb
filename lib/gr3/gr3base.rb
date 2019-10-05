# frozen_string_literal: true

module GR3
  module GR3Base
    extend GRCommons::DefineMethods
    define_ffi_methods(FFI, "gr3_")
  end
  private_constant :GR3Base

  extend GRCommons::GRCommonRule
end
