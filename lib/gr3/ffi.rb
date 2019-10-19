# frozen_string_literal: true

require 'ffi'

module GR3
  module FFI
    extend ::FFI::Library

    ffi_lib GR3.ffi_lib

    extend GRCommons::AttachFunction

    # gr3.c

    attach_function :gr3_init, %i[int], :int
    attach_function :gr3_geterror, %i[int pointer pointer], :int
    attach_function :gr3_terminate, %i[], :void
    attach_function :gr3_clear, %i[], :int
    attach_function :gr3_usecurrentframebuffer, %i[], :void
    attach_function :gr3_useframebuffer, %i[uint], :void
    attach_function :gr3_setbackgroundcolor, %i[float float float float], :void
    # getbackgroundcolor not implemented
    attach_function :gr3_createmesh_nocopy, %i[pointer int pointer pointer pointer], :int
    attach_function :gr3_createmesh, %i[pointer int pointer pointer pointer], :int
    attach_function :gr3_createindexedmesh_nocopy, %i[pointer int pointer pointer pointer int pointer], :int
    attach_function :gr3_createindexedmesh, %i[pointer int pointer pointer pointer int pointer], :int
    attach_function :gr3_drawmesh, %i[int int pointer pointer pointer pointer pointer], :void
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
    # callback :gr3_log_func, %i[string], :void
    # attach_function :gr3_setlogcallback, %i[:gr3_log_func], :void
    attach_function :gr3_geterrorstring, %i[int], :string
    attach_function :gr3_getrenderpathstring, %i[], :string
    attach_function :gr3_setobjectid, %i[int], :void
    attach_function :gr3_selectid, %i[int int int int pointer], :int
    attach_function :gr3_getviewmatrix, %i[pointer], :void
    # attach_function :gr3_setviewmatrix, %i[pointer], :void
    attach_function :gr3_getprojectiontype, %i[], :int
    attach_function :gr3_setprojectiontype, %i[int], :void

    # gr3_gr.c

    attach_function :gr3_createsurfacemesh, %i[pointer int int pointer pointer pointer int], :int
    attach_function :gr3_drawmesh_grlike, %i[int int pointer pointer pointer pointer pointer], :void
    attach_function :gr3_drawsurface, %i[int], :void
    # attach_function gr3_surface, %i[int int pointer pointer pointer int], :void
    # attach_function gr3_drawtrianglesurface, %i[int pointer], :void
    # attach_function gr_volume, %i[int int int pointer int pointer pointer], :void

    # gr3_convenience.c

    attach_function :gr3_drawcubemesh, %i[int pointer pointer pointer pointer pointer], :void
    attach_function :gr3_drawcylindermesh, %i[int pointer pointer pointer pointer pointer], :void
    attach_function :gr3_drawconemesh, %i[int pointer pointer pointer pointer pointer], :void
    attach_function :gr3_drawspheremesh, %i[int pointer pointer pointer], :void
    attach_function :gr3_drawheightmap, %i[pointer int int pointer pointer], :void
    attach_function :gr3_createheightmapmesh, %i[pointer int int], :void
    # attach_function :gr3_createisosurfacemesh,
    # %i[pointer pointer ushort uint uint uint uint uint uint double double double double double double], :int
    attach_function :gr3_drawtubemesh, %i[int pointer pointer pointer int int], :int
    # attach_function gr3_drawspins, %i[int pointer pointer pointer float float float float], :void
    # attach_function gr3_drawmolecule, %i[int pointer pointer pointer float pointer float], :void

    # gr3_slices.c

    # attach_function gr3_createxslicemesh,
    # %i[pointer pointer uint uint uint uint uint uint uint double double double double double double], :void
    # attach_function gr3_createyslicemesh
    # %i[pointer pointer uint uint uint uint uint uint uint double double double double double double], :void
    # attach_function gr3_createzslicemesh
    # %i[pointer pointer uint uint uint uint uint uint uint double double double double double double], :void
    # attach_function gr3_drawxslicemesh
    # %i[pointer uint uint uint uint uint uint uint double double double double double double], :void
    # attach_function gr3_drawyslicemesh
    # %i[pointer uint uint uint uint uint uint uint double double double double double double], :void
    # attach_function gr3_drawzslicemesh
    # %i[pointer uint uint uint uint uint uint uint double double double double double double], :void


    # gr3_mc.c

    # attach_function gr3_triangulateindexed
    # %i[pointer ushort uint uint uint uint uint uint double double double double double double pointer pointer pointer pointer poiter], :void
    # attach_function gr3_triangulate
    # %i[pointer ushort uint uint uint uint uint uint double double double double double double pointer], :void
  end
end
