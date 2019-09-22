# frozen_string_literal: true

module GR
  module FFI
    extend ::FFI::Library

    ffi_lib GR.gr_ffi_lib

    # https://github.com/sciapp/gr/blob/master/lib/gr/gr.c
    attach_function :gr_updatews, %i[], :void
    attach_function :gr_polyline, %i[int pointer pointer], :void
    attach_function :gr_polymarker, %i[int pointer pointer], :void
    attach_function :gr_gridit, %i[int pointer pointer pointer int int pointer pointer pointer], :void
    attach_function :gr_setmarkertype, %i[int], :void
    attach_function :gr_setmarkersize, %i[double], :void
    attach_function :gr_settextfontprec, %i[int int], :void
    attach_function :gr_setcharheight, %i[double], :void
    attach_function :gr_settextalign, %i[int int], :void
    attach_function :gr_setwindow, %i[double double double double], :void
    attach_function :gr_setviewport, %i[double double double double], :void
    attach_function :gr_setspace, %i[double double int int], :void
    attach_function :gr_axes, %i[double double double double int int double], :void
    attach_function :gr_surface, %i[int int pointer pointer pointer int], :void
    attach_function :gr_contour, %i[int int int pointer pointer pointer pointer int], :void
    attach_function :gr_version, %i[], :pointer
  end
end
