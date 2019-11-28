# frozen_string_literal: true

require 'fiddle/import'

module GR
  # FFI Wrapper module for GR
  module FFI
    extend Fiddle::Importer

    begin
      dlload GR.ffi_lib
    rescue LoadError
      raise LoadError, 'Could not find GR Framework'
    end

    extend GRCommons::Extern

    # https://github.com/sciapp/gr/blob/master/lib/gr/gr.h

    extern 'void gr_initgr(void)'
    extern 'void gr_opengks(void)'
    extern 'void gr_closegks(void)'
    extern 'void gr_inqdspsize(double *, double *, int *, int *)'
    extern 'void gr_openws(int, char *, int)'
    extern 'void gr_closews(int)'
    extern 'void gr_activatews(int)'
    extern 'void gr_deactivatews(int)'
    extern 'void gr_configurews(void)'
    extern 'void gr_clearws(void)'
    extern 'void gr_updatews(void)'
    extern 'void gr_polyline(int, double *, double *)'
    extern 'void gr_polymarker(int, double *, double *)'
    extern 'void gr_text(double, double, char *)'
    extern 'void gr_inqtext(double, double, char *, double *, double *)'
    extern 'void gr_fillarea(int, double *, double *)'
    extern 'void gr_cellarray(double, double, double, double, ' \
           'int, int, int, int, int, int, int *)'
    extern 'void gr_nonuniformcellarray(double *, double *, ' \
           'int, int, int, int, int, int, int *)'
    extern 'void gr_polarcellarray(double, double, double, double, double, double, ' \
           'int, int, int, int, int, int, int *)'
    extern 'void gr_gdp(int, double *, double *, int, int, int *)'
    extern 'void gr_spline(int, double *, double *, int, int)'
    extern 'void gr_gridit(int, double *, double *, double *, int, int, ' \
           'double *, double *, double *)'
    extern 'void gr_setlinetype(int)'
    extern 'void gr_inqlinetype(int *)'
    extern 'void gr_setlinewidth(double)'
    extern 'void gr_inqlinewidth(double *)'
    extern 'void gr_setlinecolorind(int)'
    extern 'void gr_inqlinecolorind(int *)'
    extern 'void gr_setmarkertype(int)'
    extern 'void gr_inqmarkertype(int *)'
    extern 'void gr_setmarkersize(double)'
    extern 'void gr_inqmarkersize(double *)'
    extern 'void gr_setmarkercolorind(int)'
    extern 'void gr_inqmarkercolorind(int *)'
    extern 'void gr_settextfontprec(int, int)'
    extern 'void gr_setcharexpan(double)'
    extern 'void gr_setcharspace(double)'
    extern 'void gr_settextcolorind(int)'
    extern 'void gr_setcharheight(double)'
    extern 'void gr_setcharup(double, double)'
    extern 'void gr_settextpath(int)'
    extern 'void gr_settextalign(int, int)'
    extern 'void gr_setfillintstyle(int)'
    extern 'void gr_inqfillintstyle(int *)'
    extern 'void gr_setfillstyle(int)'
    extern 'void gr_inqfillstyle(int *)'
    extern 'void gr_setfillcolorind(int)'
    extern 'void gr_inqfillcolorind(int *)'
    extern 'void gr_setcolorrep(int, double, double, double)'
    extern 'void gr_setwindow(double, double, double, double)'
    extern 'void gr_inqwindow(double *, double *, double *, double *)'
    extern 'void gr_setviewport(double, double, double, double)'
    extern 'void gr_inqviewport(double *, double *, double *, double *)'
    extern 'void gr_selntran(int)'
    extern 'void gr_setclip(int)'
    extern 'void gr_setwswindow(double, double, double, double)'
    extern 'void gr_setwsviewport(double, double, double, double)'
    extern 'void gr_createseg(int)'
    extern 'void gr_copysegws(int)'
    extern 'void gr_redrawsegws(void)'
    extern 'void gr_setsegtran(int, double, double, double, double, double, double, double)'
    extern 'void gr_closeseg(void)'
    extern 'void gr_emergencyclosegks(void)'
    extern 'void gr_updategks(void)'
    extern 'int gr_setspace(double, double, int, int)'
    extern 'void gr_inqspace(double *, double *, int *, int *)'
    extern 'int gr_setscale(int)'
    extern 'void gr_inqscale(int *)'
    extern 'int gr_textext(double, double, char *)'
    extern 'void gr_inqtextext(double, double, char *, double *, double *)'
    extern 'void gr_axes(double, double, double, double, int, int, double)'
    extern 'void gr_axeslbl(double, double, double, double, int, int, double,' \
           'void (*)(double, double, const char *, double),' \
           'void (*)(double, double, const char *, double))'
    extern 'void gr_grid(double, double, double, double, int, int)'
    extern 'void gr_grid3d(double, double, double, double, double, double, int, int, int)'
    extern 'void gr_verrorbars(int, double *, double *, double *, double *)'
    extern 'void gr_herrorbars(int, double *, double *, double *, double *)'
    extern 'void gr_polyline3d(int, double *, double *, double *)'
    extern 'void gr_polymarker3d(int, double *, double *, double *)'
    extern 'void gr_axes3d(double, double, double, double, double, double, int, int, int, double)'
    extern 'void gr_titles3d(char *, char *, char *)'
    extern 'void gr_surface(int, int, double *, double *, double *, int)'
    extern 'void gr_contour(int, int, int, double *, double *, double *, double *, int)'
    extern 'void gr_contourf(int, int, int, double *, double *, double *, double *, int)'
    extern 'void gr_tricontour(int, double *, double *, double *, int, double *)'
    extern 'int gr_hexbin(int, double *, double *, int)'
    extern 'void gr_setcolormap(int)'
    extern 'void gr_inqcolormap(int *)'
    extern 'void gr_setcolormapfromrgb(int n, double *r, double *g, double *b, double *x)'
    extern 'void gr_colorbar(void)'
    extern 'void gr_inqcolor(int, int *)'
    extern 'int gr_inqcolorfromrgb(double, double, double)'
    extern 'void gr_hsvtorgb(double h, double s, double v, double *r, double *g, double *b)'
    extern 'double gr_tick(double, double)'
    extern 'int gr_validaterange(double, double)'
    extern 'void gr_adjustlimits(double *, double *)'
    extern 'void gr_adjustrange(double *, double *)'
    extern 'void gr_beginprint(char *)'
    extern 'void gr_beginprintext(char *, char *, char *, char *)'
    extern 'void gr_endprint(void)'
    extern 'void gr_ndctowc(double *, double *)'
    extern 'void gr_wctondc(double *, double *)'
    extern 'void gr_wc3towc(double *, double *, double *)'
    extern 'void gr_drawrect(double, double, double, double)'
    extern 'void gr_fillrect(double, double, double, double)'
    extern 'void gr_drawarc(double, double, double, double, double, double)'
    extern 'void gr_fillarc(double, double, double, double, double, double)'
    extern 'void gr_drawpath(int, vertex_t *, unsigned char *, int)'
    extern 'void gr_setarrowstyle(int)'
    extern 'void gr_setarrowsize(double)'
    extern 'void gr_drawarrow(double, double, double, double)'
    extern 'int gr_readimage(char *, int *, int *, int **)'
    extern 'void gr_drawimage(double, double, double, double, int, int, int *, int)'
    extern 'int gr_importgraphics(char *)'
    extern 'void gr_setshadow(double, double, double)'
    extern 'void gr_settransparency(double)'
    extern 'void gr_setcoordxform(double[3][2])'
    extern 'void gr_begingraphics(char *)'
    extern 'void gr_endgraphics(void)'
    extern 'char *gr_getgraphics(void)'
    extern 'int gr_drawgraphics(char *)'
    extern 'void gr_mathtex(double, double, char *)'
    extern 'void gr_inqmathtex(double, double, char *, double *, double *)'
    extern 'void gr_beginselection(int, int)'
    extern 'void gr_endselection(void)'
    extern 'void gr_moveselection(double, double)'
    extern 'void gr_resizeselection(int, double, double)'
    extern 'void gr_inqbbox(double *, double *, double *, double *)'
    extern 'double gr_precision(void)'
    extern 'void gr_setregenflags(int)'
    extern 'int gr_inqregenflags(void)'
    extern 'void gr_savestate(void)'
    extern 'void gr_restorestate(void)'
    extern 'void gr_selectcontext(int)'
    extern 'void gr_destroycontext(int)'
    extern 'int gr_uselinespec(char *)'
    # extern 'void gr_delaunay(int, const double *, const double *, int *, int **)'
    extern 'void gr_reducepoints(int, const double *, const double *, int, double *, double *)'
    extern 'void gr_trisurface(int, double *, double *, double *)'
    extern 'void gr_gradient(int, int, double *, double *, double *, double *, double *)'
    extern 'void gr_quiver(int, int, double *, double *, double *, double *, int)'
    extern 'void gr_interp2(int nx, int ny, const double *x, const double *y, const double *z,' \
           'int nxq, int nyq, const double *xq, const double *yq, double *zq, int method, double extrapval)'
    # extern :gr_newmeta
    # extern :gr_deletemeta
    # extern :gr_finalizemeta
    # extern :gr_meta_args_push
    # extern :gr_meta_args_push_buf
    # extern :gr_meta_args_contains
    # extern :gr_meta_args_clear
    # extern :gr_meta_args_remove
    # extern :gr_meta_get_box
    # extern :gr_openmeta
    # extern :gr_recvmeta
    # extern :gr_sendmeta
    # extern :gr_sendmeta_buf
    # extern :gr_sendmeta_ref
    # extern :gr_sendmeta_args
    # extern :gr_closemeta
    # extern :gr_clearmeta
    # extern :gr_inputmeta
    # extern :gr_mergemeta
    # extern :gr_plotmeta
    # extern :gr_readmeta
    # extern :gr_switchmeta
    # extern :gr_registermeta
    # extern :gr_unregistermeta
    # extern :gr_meta_max_plotid
    # extern :gr_dumpmeta
    # extern :gr_dumpmeta_json

    extern 'const char *gr_version(void)'
    extern 'void gr_shade(int, double *, double *, int, int, double *, int, int, int *)'
    extern 'void gr_shadepoints(int, double *, double *, int, int, int)'
    extern 'void gr_shadelines(int, double *, double *, int, int, int)'
    extern 'void gr_panzoom(double, double, double, double, double *, double *, double *, double *)'
    # extern 'int gr_findboundary(int, double *, double *, double, double (*)(double, double), int, int *)'
    extern 'void gr_setresamplemethod(unsigned int flag)'
    extern 'void gr_inqresamplemethod(unsigned int *flag)'
    extern 'void gr_path(int, double *, double *, char *)'
  end
end
