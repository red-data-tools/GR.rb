# frozen_string_literal: true

require 'ffi'

module GR3
  module FFI
    extend ::FFI::Library

    ffi_lib GR3.ffi_lib
  end
end
