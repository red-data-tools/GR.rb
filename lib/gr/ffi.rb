# frozen_string_literal: true

module GR
  module FFI
    extend ::FFI::Library

    ffi_lib GR.gr_ffi_lib

    # https://github.com/sciapp/gr/blob/master/lib/gr/gr.c
    attach_function :gr_setviewport, %i[double double double double], :void
    attach_function :gr_axes, %i[double double double double int int double], :void
    attach_function :gr_polyline, %i[int pointer pointer], :void
    attach_function :gr_version, %i[], :pointer
  end
end
