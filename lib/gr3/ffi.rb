# frozen_string_literal: true

require 'ffi'

module GR3
  module FFI
    extend ::FFI::Library

    ffi_lib GR3.ffi_lib

    extend GRCommons::AttachFunction

    # TODO: Error
    attach_function :gr3_init, %i[int], :int
    attach_function :gr3_geterror, %i[int pointer pointer], :int
    attach_function :gr3_terminate, %i[], :void
    attach_function :gr3_clear, %i[], :int
    attach_function :gr3_usecurrentframebuffer, %i[], :void
    attach_function :gr3_useframebuffer, %i[uint], :void
    attach_function :gr3_setbackgroundcolor, %i[float float float float], :void
    # getbackgroundcolor not implemented
    # attach_function :gr3_createmesh_nocopy, %i[pinter int pointer pointer pointer], :int
    # attach_function :gr3_createmesh
    attach_function :gr3_createindexedmesh_nocopy, %i[pointer int pointer pointer pointer int pointer], :int
    # attach_function :gr3_createindexedmesh
    # attach_function :gr3_drawmesh
    attach_function :gr3_deletemesh, %i[int], :void
    attach_function :gr3_setlightdirection, %i[float float float], :void
    attach_function :gr3_cameralookat, %i[float float float float float float float float float], :void
    attach_function :gr3_setcameraprojectionparameters, %i[float float float], :int
    attach_function :gr3_getcameraprojectionparameters, %i[pointer pointer pointer], :int
    attach_function :gr3_drawimage, %i[float float float float int int int], :int
    attach_function :gr3_setquality, %i[int], :int
    attach_function :gr3_getimage, %i[int int int pointer], :int
    attach_function :gr3_export, %i[pointer int int], :int
    attach_function :gr3_free, %i[pointer], :void
    # attach_function :gr3_setlogcallback
    attach_function :gr3_geterrorstring, %i[int], :string
    # gr3_getrenderpathstring
    attach_function :gr3_setobjectid, %i[int], :void
    attach_function :gr3_selectid, %i[int int int int pointer], :int
    attach_function :gr3_getviewmatrix, %i[pointer], :void
    # attach_function :gr3_setviewmatrix
    attach_function :gr3_getprojectiontype, %i[], :int
    attach_function :gr3_setprojectiontype, %i[int], :void

    # gr3_convenience.c

    # attach_function :gr3_drawcubemesh, %i[int pointer pointer pointer pointer pointer], :void
    attach_function :gr3_drawcylindermesh, %i[int pointer pointer pointer pointer pointer], :void
    # attach_function gr3_drawconemesh, %i[int pointer pointer pointer pointer pointer], :void
    attach_function :gr3_drawspheremesh, %i[int pointer pointer pointer], :void
    # attach_function gr3_drawheightmap, %i[pointer int int pointer pointer], :void
    # attach_function gr3_createheightmapmesh, %i[pointer int int], :void
    # attach_function gr3_createisosurfacemesh
    attach_function :gr3_drawtubemesh, %i[int pointer pointer pointer int int], :int
    # attach_function gr3_drawspins, %i[int pointer pointer pointer float float float float], :void
    # attach_function gr3_drawmolecule
  end
end
