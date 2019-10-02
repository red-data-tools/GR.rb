# frozen_string_literal: true

require 'ffi'

module GR3
  module FFI
    extend ::FFI::Library

    ffi_lib GR.ffi_lib

    extend GRCommons::RegisterMethods
  end
end
