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
    # Order is important.

    try_extern 'void gr_initgr(void)'
    try_extern 'void gr_opengks(void)'
    try_extern 'void gr_closegks(void)'
    try_extern 'void gr_inqdspsize(double *, double *, int *, int *)'
    try_extern 'void gr_openws(int, char *, int)'
    try_extern 'void gr_closews(int)'
    try_extern 'void gr_activatews(int)'
    try_extern 'void gr_deactivatews(int)'
    try_extern 'void gr_configurews(void)'
    try_extern 'void gr_clearws(void)'
    try_extern 'void gr_updatews(void)'
    try_extern 'void gr_polyline(int, double *, double *)'
    try_extern 'void gr_polymarker(int, double *, double *)'
    try_extern 'void gr_text(double, double, char *)'
    try_extern 'void gr_inqtext(double, double, char *, double *, double *)'
    try_extern 'void gr_fillarea(int, double *, double *)'
    try_extern 'void gr_cellarray(double, double, double, double, ' \
           'int, int, int, int, int, int, int *)'
    try_extern 'void gr_nonuniformcellarray(double *, double *, ' \
           'int, int, int, int, int, int, int *)'
    try_extern 'void gr_polarcellarray(double, double, double, double, double, double, ' \
           'int, int, int, int, int, int, int *)'
    try_extern 'void gr_gdp(int, double *, double *, int, int, int *)'
    try_extern 'void gr_spline(int, double *, double *, int, int)'
    try_extern 'void gr_gridit(int, double *, double *, double *, int, int, ' \
           'double *, double *, double *)'
    try_extern 'void gr_setlinetype(int)'
    try_extern 'void gr_inqlinetype(int *)'
    try_extern 'void gr_setlinewidth(double)'
    try_extern 'void gr_inqlinewidth(double *)'
    try_extern 'void gr_setlinecolorind(int)'
    try_extern 'void gr_inqlinecolorind(int *)'
    try_extern 'void gr_setmarkertype(int)'
    try_extern 'void gr_inqmarkertype(int *)'
    try_extern 'void gr_setmarkersize(double)'
    try_extern 'void gr_inqmarkersize(double *)'
    try_extern 'void gr_setmarkercolorind(int)'
    try_extern 'void gr_inqmarkercolorind(int *)'
    try_extern 'void gr_settextfontprec(int, int)'
    try_extern 'void gr_setcharexpan(double)'
    try_extern 'void gr_setcharspace(double)'
    try_extern 'void gr_settextcolorind(int)'
    try_extern 'void gr_setcharheight(double)'
    try_extern 'void gr_setcharup(double, double)'
    try_extern 'void gr_settextpath(int)'
    try_extern 'void gr_settextalign(int, int)'
    try_extern 'void gr_setfillintstyle(int)'
    try_extern 'void gr_inqfillintstyle(int *)'
    try_extern 'void gr_setfillstyle(int)'
    try_extern 'void gr_inqfillstyle(int *)'
    try_extern 'void gr_setfillcolorind(int)'
    try_extern 'void gr_inqfillcolorind(int *)'
    try_extern 'void gr_setcolorrep(int, double, double, double)'
    try_extern 'void gr_setwindow(double, double, double, double)'
    try_extern 'void gr_inqwindow(double *, double *, double *, double *)'
    try_extern 'void gr_setviewport(double, double, double, double)'
    try_extern 'void gr_inqviewport(double *, double *, double *, double *)'
    try_extern 'void gr_selntran(int)'
    try_extern 'void gr_setclip(int)'
    try_extern 'void gr_setwswindow(double, double, double, double)'
    try_extern 'void gr_setwsviewport(double, double, double, double)'
    try_extern 'void gr_createseg(int)'
    try_extern 'void gr_copysegws(int)'
    try_extern 'void gr_redrawsegws(void)'
    try_extern 'void gr_setsegtran(int, double, double, double, double, double, double, double)'
    try_extern 'void gr_closeseg(void)'
    try_extern 'void gr_emergencyclosegks(void)'
    try_extern 'void gr_updategks(void)'
    try_extern 'int gr_setspace(double, double, int, int)'
    try_extern 'void gr_inqspace(double *, double *, int *, int *)'
    try_extern 'int gr_setscale(int)'
    try_extern 'void gr_inqscale(int *)'
    try_extern 'int gr_textext(double, double, char *)'
    try_extern 'void gr_inqtextext(double, double, char *, double *, double *)'
    try_extern 'void gr_axes(double, double, double, double, int, int, double)'
    try_extern 'void gr_axeslbl(double, double, double, double, int, int, double,' \
           'void (*)(double, double, const char *, double),' \
           'void (*)(double, double, const char *, double))'
    try_extern 'void gr_grid(double, double, double, double, int, int)'
    try_extern 'void gr_grid3d(double, double, double, double, double, double, int, int, int)'
    try_extern 'void gr_verrorbars(int, double *, double *, double *, double *)'
    try_extern 'void gr_herrorbars(int, double *, double *, double *, double *)'
    try_extern 'void gr_polyline3d(int, double *, double *, double *)'
    try_extern 'void gr_polymarker3d(int, double *, double *, double *)'
    try_extern 'void gr_axes3d(double, double, double, double, double, double, int, int, int, double)'
    try_extern 'void gr_titles3d(char *, char *, char *)'
    try_extern 'void gr_surface(int, int, double *, double *, double *, int)'
    try_extern 'void gr_contour(int, int, int, double *, double *, double *, double *, int)'
    try_extern 'void gr_contourf(int, int, int, double *, double *, double *, double *, int)'
    try_extern 'void gr_tricontour(int, double *, double *, double *, int, double *)'
    try_extern 'int gr_hexbin(int, double *, double *, int)'
    try_extern 'void gr_setcolormap(int)'
    try_extern 'void gr_inqcolormap(int *)'
    try_extern 'void gr_setcolormapfromrgb(int n, double *r, double *g, double *b, double *x)'
    try_extern 'void gr_colorbar(void)'
    try_extern 'void gr_inqcolor(int, int *)'
    try_extern 'int gr_inqcolorfromrgb(double, double, double)'
    try_extern 'void gr_hsvtorgb(double h, double s, double v, double *r, double *g, double *b)'
    try_extern 'double gr_tick(double, double)'
    try_extern 'int gr_validaterange(double, double)'
    try_extern 'void gr_adjustlimits(double *, double *)'
    try_extern 'void gr_adjustrange(double *, double *)'
    try_extern 'void gr_beginprint(char *)'
    try_extern 'void gr_beginprintext(char *, char *, char *, char *)'
    try_extern 'void gr_endprint(void)'
    try_extern 'void gr_ndctowc(double *, double *)'
    try_extern 'void gr_wctondc(double *, double *)'
    try_extern 'void gr_wc3towc(double *, double *, double *)'
    try_extern 'void gr_drawrect(double, double, double, double)'
    try_extern 'void gr_fillrect(double, double, double, double)'
    try_extern 'void gr_drawarc(double, double, double, double, double, double)'
    try_extern 'void gr_fillarc(double, double, double, double, double, double)'
    try_extern 'void gr_drawpath(int, vertex_t *, unsigned char *, int)'
    try_extern 'void gr_setarrowstyle(int)'
    try_extern 'void gr_setarrowsize(double)'
    try_extern 'void gr_drawarrow(double, double, double, double)'
    try_extern 'int gr_readimage(char *, int *, int *, int **)'
    try_extern 'void gr_drawimage(double, double, double, double, int, int, int *, int)'
    try_extern 'int gr_importgraphics(char *)'
    try_extern 'void gr_setshadow(double, double, double)'
    try_extern 'void gr_settransparency(double)'
    try_extern 'void gr_setcoordxform(double[3][2])'
    try_extern 'void gr_begingraphics(char *)'
    try_extern 'void gr_endgraphics(void)'
    try_extern 'char *gr_getgraphics(void)'
    try_extern 'int gr_drawgraphics(char *)'
    try_extern 'void gr_mathtex(double, double, char *)'
    try_extern 'void gr_inqmathtex(double, double, char *, double *, double *)'
    try_extern 'void gr_beginselection(int, int)'
    try_extern 'void gr_endselection(void)'
    try_extern 'void gr_moveselection(double, double)'
    try_extern 'void gr_resizeselection(int, double, double)'
    try_extern 'void gr_inqbbox(double *, double *, double *, double *)'
    try_extern 'double gr_precision(void)'
    try_extern 'void gr_setregenflags(int)'
    try_extern 'int gr_inqregenflags(void)'
    try_extern 'void gr_savestate(void)'
    try_extern 'void gr_restorestate(void)'
    try_extern 'void gr_selectcontext(int)'
    try_extern 'void gr_destroycontext(int)'
    try_extern 'int gr_uselinespec(char *)'
    # try_extern 'void gr_delaunay(int, const double *, const double *, int *, int **)'
    try_extern 'void gr_reducepoints(int, const double *, const double *, int, double *, double *)'
    try_extern 'void gr_trisurface(int, double *, double *, double *)'
    try_extern 'void gr_gradient(int, int, double *, double *, double *, double *, double *)'
    try_extern 'void gr_quiver(int, int, double *, double *, double *, double *, int)'
    try_extern 'void gr_interp2(int nx, int ny, const double *x, const double *y, const double *z,' \
           'int nxq, int nyq, const double *xq, const double *yq, double *zq, int method, double extrapval)'
    # try_extern :gr_newmeta
    # try_extern :gr_deletemeta
    # try_extern :gr_finalizemeta
    # try_extern :gr_meta_args_push
    # try_extern :gr_meta_args_push_buf
    # try_extern :gr_meta_args_contains
    # try_extern :gr_meta_args_clear
    # try_extern :gr_meta_args_remove
    # try_extern :gr_meta_get_box
    # try_extern :gr_openmeta
    # try_extern :gr_recvmeta
    # try_extern :gr_sendmeta
    # try_extern :gr_sendmeta_buf
    # try_extern :gr_sendmeta_ref
    # try_extern :gr_sendmeta_args
    # try_extern :gr_closemeta
    # try_extern :gr_clearmeta
    # try_extern :gr_inputmeta
    # try_extern :gr_mergemeta
    # try_extern :gr_plotmeta
    # try_extern :gr_readmeta
    # try_extern :gr_switchmeta
    # try_extern :gr_registermeta
    # try_extern :gr_unregistermeta
    # try_extern :gr_meta_max_plotid
    # try_extern :gr_dumpmeta
    # try_extern :gr_dumpmeta_json

    try_extern 'const char *gr_version(void)'
    try_extern 'void gr_shade(int, double *, double *, int, int, double *, int, int, int *)'
    try_extern 'void gr_shadepoints(int, double *, double *, int, int, int)'
    try_extern 'void gr_shadelines(int, double *, double *, int, int, int)'
    try_extern 'void gr_panzoom(double, double, double, double, double *, double *, double *, double *)'
    # try_extern 'int gr_findboundary(int, double *, double *, double, double (*)(double, double), int, int *)'
    try_extern 'void gr_setresamplemethod(unsigned int flag)'
    try_extern 'void gr_inqresamplemethod(unsigned int *flag)'
    try_extern 'void gr_path(int, double *, double *, const char *)'
    try_extern 'void gr_setborderwidth(double)'
    try_extern 'void gr_inqborderwidth(double *)'
    try_extern 'void gr_setbordercolorind(int)'
    try_extern 'void gr_inqbordercolorind(int *)'
    try_extern 'void gr_setprojectiontype(int)'
    try_extern 'void gr_inqprojectiontype(int *)'
    try_extern 'void gr_setperspectiveprojection(double, double, double)'
    try_extern 'void gr_inqperspectiveprojection(double *, double *, double *)'
    try_extern 'void gr_settransformationparameters(double, double, double, double, double, double, double, double, double)'
    try_extern 'void gr_inqtransformationparameters(double *, double *, double *, double *, double *, double *, double *,
                                              double *, double *);'
    try_extern 'void gr_setorthographicprojection(double, double, double, double, double, double)'
    try_extern 'void gr_inqorthographicprojection(double *, double *, double *, double *, double *, double *)'
  end
end
