# frozen_string_literal: true

require 'ffi'

module GR3
  module FFI
    extend ::FFI::Library

    ffi_lib GR3.ffi_lib

    extend GRCommons::RegisterMethods

    attach_function :gr3_clear, %i[], :void
  end
end
