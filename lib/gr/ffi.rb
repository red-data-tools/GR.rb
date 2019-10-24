# frozen_string_literal: true

require 'ffi'

module GR
  module FFI
    extend ::FFI::Library

    begin
      ffi_lib GR.ffi_lib
    rescue LoadError => e
      raise LoadError, 'Could not find GR Framework'
    end

    extend GRCommons::AttachFunction

    # https://github.com/sciapp/gr/blob/master/lib/gr/gr.h

    attach_function :gr_initgr, %i[], :void
    attach_function :gr_opengks, %i[], :void
    attach_function :gr_closegks, %i[], :void
    attach_function :gr_inqdspsize, %i[pointer pointer pointer pointer], :void
    attach_function :gr_openws, %i[int string int], :void
    attach_function :gr_closews, %i[int], :void
    attach_function :gr_activatews, %i[int], :void
    attach_function :gr_deactivatews, %i[int], :void
    attach_function :gr_configurews, %i[], :void
    attach_function :gr_clearws, %i[], :void
    attach_function :gr_updatews, %i[], :void
    attach_function :gr_polyline, %i[int pointer pointer], :void
    attach_function :gr_polymarker, %i[int pointer pointer], :void
    attach_function :gr_text, %i[double double string], :void
    attach_function :gr_inqtext, %i[double double string pointer pointer], :void
    attach_function :gr_fillarea, %i[int pointer pointer], :void
    attach_function :gr_cellarray, %i[double double double double int int int int int int pointer], :void
    attach_function :gr_nonuniformcellarray, %i[pointer pointer int int int int int int pointer], :void
    attach_function :gr_polarcellarray, %i[double double double double double double int int int int int int pointer], :void
    attach_function :gr_gdp, %i[int pointer pointer int int pointer], :void
    attach_function :gr_spline, %i[int pointer pointer int int], :void
    attach_function :gr_gridit, %i[int pointer pointer pointer int int pointer pointer pointer], :void
    attach_function :gr_setlinetype, %i[int], :void
    attach_function :gr_inqlinetype, %i[pointer], :void
    attach_function :gr_setlinewidth, %i[double], :void
    attach_function :gr_inqlinewidth, %i[pointer], :void
    attach_function :gr_setlinecolorind, %i[int], :void
    attach_function :gr_inqlinecolorind, %i[pointer], :void
    attach_function :gr_setmarkertype, %i[int], :void
    attach_function :gr_inqmarkertype, %i[pointer], :void
    attach_function :gr_setmarkersize, %i[double], :void
    attach_function :gr_inqmarkersize, %i[pointer], :void
    attach_function :gr_setmarkercolorind, %i[int], :void
    attach_function :gr_inqmarkercolorind, %i[pointer], :void
    attach_function :gr_settextfontprec, %i[int int], :void
    attach_function :gr_setcharexpan, %i[double], :void
    attach_function :gr_setcharspace, %i[double], :void
    attach_function :gr_settextcolorind, %i[int], :void
    attach_function :gr_setcharheight, %i[double], :void
    attach_function :gr_setcharup, %i[double double], :void
    attach_function :gr_settextpath, %i[int], :void
    attach_function :gr_settextalign, %i[int int], :void
    attach_function :gr_setfillintstyle, %i[int], :void
    attach_function :gr_inqfillintstyle, %i[pointer], :void
    attach_function :gr_setfillstyle, %i[int], :void
    attach_function :gr_inqfillstyle, %i[pointer], :void
    attach_function :gr_setfillcolorind, %i[int], :void
    attach_function :gr_inqfillcolorind, %i[pointer], :void
    attach_function :gr_setcolorrep, %i[int double double double], :void
    attach_function :gr_setscale, %i[int], :int
    attach_function :gr_inqscale, %i[pointer], :void
    attach_function :gr_setwindow, %i[double double double double], :void
    attach_function :gr_inqwindow, %i[pointer pointer pointer pointer], :void
    attach_function :gr_setviewport, %i[double double double double], :void
    attach_function :gr_inqviewport, %i[pointer pointer pointer pointer], :void
    attach_function :gr_selntran, %i[int], :void
    attach_function :gr_setclip, %i[int], :void
    attach_function :gr_setwswindow, %i[double double double double], :void
    attach_function :gr_setwsviewport, %i[double double double double], :void
    attach_function :gr_createseg, %i[int], :void
    attach_function :gr_copysegws, %i[int], :void
    attach_function :gr_redrawsegws, %i[], :void
    attach_function :gr_setsegtran, %i[int double double double double double double double], :void
    attach_function :gr_closeseg, %i[], :void
    attach_function :gr_emergencyclosegks, %i[], :void
    attach_function :gr_updategks, %i[], :void
    attach_function :gr_setspace, %i[double double int int], :void
    attach_function :gr_inqspace, %i[pointer pointer pointer pointer], :void
    attach_function :gr_textext, %i[double double string], :int
    attach_function :gr_inqtextext, %i[double double string pointer pointer], :void
    attach_function :gr_axes, %i[double double double double int int double], :void
    # attach_function :gr_axeslbl
    attach_function :gr_grid, %i[double double double double int int], :void
    attach_function :gr_grid3d, %i[double double double double double double int int int], :void
    attach_function :gr_verrorbars, %i[int pointer pointer pointer pointer], :void
    attach_function :gr_herrorbars, %i[int pointer pointer pointer pointer], :void
    attach_function :gr_polyline3d, %i[int pointer pointer pointer], :void
    attach_function :gr_polymarker3d, %i[int pointer pointer pointer], :void
    attach_function :gr_axes3d, %i[double double double double double double int int int double], :void
    attach_function :gr_titles3d, %i[string string string], :void
    attach_function :gr_surface, %i[int int pointer pointer pointer int], :void
    attach_function :gr_contour, %i[int int int pointer pointer pointer pointer int], :void
    attach_function :gr_contourf, %i[int int int pointer pointer pointer pointer int], :void
    attach_function :gr_tricontour, %i[int pointer pointer pointer int pointer], :void
    attach_function :gr_hexbin, %i[int pointer pointer int], :int
    attach_function :gr_setcolormap, %i[int], :void
    attach_function :gr_inqcolormap, %i[pointer], :void
    attach_function :gr_setcolormapfromrgb, %i[int pointer pointer pointer pointer], :void
    attach_function :gr_colorbar, %i[], :void
    attach_function :gr_inqcolor, %i[int pointer], :void
    attach_function :gr_inqcolorfromrgb, %i[double double double], :int
    attach_function :gr_hsvtorgb, %i[double double double pointer pointer pointer], :void
    attach_function :gr_tick, %i[double double], :double
    attach_function :gr_validaterange, %i[double double], :int
    attach_function :gr_adjustlimits, %i[pointer pointer], :void
    attach_function :gr_adjustrange, %i[pointer pointer], :void
    attach_function :gr_beginprint, %i[string], :void
    attach_function :gr_beginprintext, %i[string string string string], :void
    attach_function :gr_endprint, %i[], :void
    attach_function :gr_ndctowc, %i[pointer pointer], :void
    attach_function :gr_wctondc, %i[pointer pointer], :void
    attach_function :gr_wc3towc, %i[pointer pointer pointer], :void
    attach_function :gr_drawrect, %i[double double double double], :void
    attach_function :gr_fillrect, %i[double double double double], :void
    attach_function :gr_drawarc, %i[double double double double double double], :void
    attach_function :gr_fillarc, %i[double double double double double double], :void
    attach_function :gr_drawpath, %i[int pointer pointer int], :void
    attach_function :gr_setarrowstyle, %i[int], :void
    attach_function :gr_setarrowsize, %i[double], :void
    attach_function :gr_drawarrow, %i[double double double double], :void
    attach_function :gr_readimage, %i[string pointer pointer pointer], :int
    attach_function :gr_drawimage, %i[double double double double int int pointer int], :void
    attach_function :gr_importgraphics, %i[string], :int
    attach_function :gr_setshadow, %i[double double double], :void
    attach_function :gr_settransparency, %i[double], :void
    attach_function :gr_setcoordxform, %i[pointer], :void
    attach_function :gr_begingraphics, %i[string], :void
    attach_function :gr_endgraphics, %i[], :void
    attach_function :gr_getgraphics, %i[], :string
    attach_function :gr_drawgraphics, %i[string], :int
    attach_function :gr_mathtex, %i[double double string], :void
    attach_function :gr_inqmathtex, %i[double double string pointer pointer], :void
    attach_function :gr_beginselection, %i[int int], :void
    attach_function :gr_endselection, %i[], :void
    attach_function :gr_moveselection, %i[double double], :void
    attach_function :gr_resizeselection, %i[int double double], :void
    attach_function :gr_inqbbox, %i[pointer pointer pointer pointer], :void
    attach_function :gr_precision, %i[], :void
    attach_function :gr_setregenflags, %i[int], :void
    attach_function :gr_inqregenflags, %i[], :void
    attach_function :gr_savestate, %i[], :void
    attach_function :gr_restorestate, %i[], :void
    attach_function :gr_selectcontext, %i[int], :void
    attach_function :gr_destroycontext, %i[int], :void
    attach_function :gr_uselinespec, %i[string], :void
    # attach_function :gr_delaunay, %i[int pointer pointer pointer pointer], :void
    attach_function :gr_reducepoints, %i[int pointer pointer int pointer pointer], :void
    attach_function :gr_trisurface, %i[int pointer pointer pointer], :void
    attach_function :gr_gradient, %i[int int pointer pointer pointer pointer pointer], :void
    attach_function :gr_quiver, %i[int int pointer pointer pointer pointer int], :void
    attach_function :gr_interp2, %i[int int pointer pointer pointer int int pointer pointer pointer int double], :void

    # attach_function :gr_newmeta
    # attach_function :gr_deletemeta
    # attach_function :gr_finalizemeta
    # attach_function :gr_meta_args_push
    # attach_function :gr_meta_args_push_buf
    # attach_function :gr_meta_args_contains
    # attach_function :gr_meta_args_clear
    # attach_function :gr_meta_args_remove
    # attach_function :gr_meta_get_box
    # attach_function :gr_openmeta
    # attach_function :gr_recvmeta
    # attach_function :gr_sendmeta
    # attach_function :gr_sendmeta_buf
    # attach_function :gr_sendmeta_ref
    # attach_function :gr_sendmeta_args
    # attach_function :gr_closemeta
    # attach_function :gr_clearmeta
    # attach_function :gr_inputmeta
    # attach_function :gr_mergemeta
    # attach_function :gr_plotmeta
    # attach_function :gr_readmeta
    # attach_function :gr_switchmeta
    # attach_function :gr_registermeta
    # attach_function :gr_unregistermeta
    # attach_function :gr_meta_max_plotid
    # attach_function :gr_dumpmeta
    # attach_function :gr_dumpmeta_json

    attach_function :gr_version, %i[], :pointer
    attach_function :gr_shadepoints, %i[int pointer pointer int int int], :void
    attach_function :gr_shadelines, %i[int pointer pointer int int int], :void
    attach_function :gr_panzoom, %i[double double double double pointer pointer pointer pointer], :void
    # attach_function :gr_findboundary
  end
end
