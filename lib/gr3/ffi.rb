# frozen_string_literal: true

require 'fiddle/import'

module GR3
  # FFI Wrapper module for GR3
  module FFI
    extend Fiddle::Importer

    begin
      dlload GR3.ffi_lib
    rescue LoadError
      raise LoadError, 'Could not find GR Framework'
    end

    extend GRCommons::Extern

    # https://github.com/sciapp/gr/blob/master/lib/gr3/gr3.h

    extern 'int gr3_init(int *attrib_list)'
    extern 'void gr3_free(void *pointer)'
    extern 'void gr3_terminate(void)'
    extern 'int gr3_geterror(int clear, int *line, const char **file)'
    extern 'const char *gr3_getrenderpathstring(void)'
    extern 'const char *gr3_geterrorstring(int error)'
    # extern 'void gr3_setlogcallback(void (*gr3_log_func)(const char *log_message))'
    extern 'int gr3_clear(void)'
    extern 'void gr3_usecurrentframebuffer()'
    extern 'void gr3_useframebuffer(unsigned int framebuffer)'
    extern 'int gr3_setquality(int quality)'
    extern 'int gr3_getimage(int width, int height, int use_alpha, char *pixels)'
    extern 'int gr3_export(const char *filename, int width, int height)'
    extern 'int gr3_drawimage(float xmin, float xmax, float ymin, float ymax, ' \
           'int width, int height, int drawable_type)'
    extern 'int gr3_createmesh_nocopy(int *mesh, int n, ' \
           'float *vertices, float *normals, float *colors)'
    extern 'int gr3_createmesh(int *mesh, int n, ' \
           'const float *vertices, const float *normals, const float *colors)'
    extern 'int gr3_createindexedmesh_nocopy(int *mesh, int number_of_vertices, ' \
           'float *vertices, float *normals, float *colors, int number_of_indices, int *indices)'
    extern 'int gr3_createindexedmesh(int *mesh, int number_of_vertices, ' \
           'const float *vertices, const float *normals, const float *colors, ' \
           'int number_of_indices, const int *indices)'
    extern 'void gr3_drawmesh(int mesh, int n, ' \
           'const float *positions, const float *directions, const float *ups, ' \
           'const float *colors, const float *scales)'
    extern 'void gr3_deletemesh(int mesh)'
    extern 'void gr3_cameralookat(float camera_x, float camera_y, float camera_z, ' \
           'float center_x, float center_y, float center_z, ' \
           'float up_x, float up_y, float up_z)'
    extern 'int gr3_setcameraprojectionparameters(float vertical_field_of_view, ' \
           'float zNear, float zFar)'
    extern 'int gr3_getcameraprojectionparameters(float *vfov, float *znear, float *zfar)'
    extern 'void gr3_setlightdirection(float x, float y, float z)'
    extern 'void gr3_setbackgroundcolor(float red, float green, float blue, float alpha)'
    extern 'int gr3_createheightmapmesh(const float *heightmap, int num_columns, int num_rows)'
    extern 'void gr3_drawheightmap(const float *heightmap, ' \
           'int num_columns, int num_rows, const float *positions, const float *scales)'
    extern 'void gr3_drawconemesh(int n, const float *positions, const float *directions, ' \
           'const float *colors, const float *radii, const float *lengths)'
    extern 'void gr3_drawcylindermesh(int n, const float *positions, const float *directions, ' \
           'const float *colors, const float *radii, const float *lengths)'
    extern 'void gr3_drawspheremesh(int n, const float *positions, ' \
           'const float *colors, const float *radii)'
    extern 'void gr3_drawcubemesh(int n, ' \
           'const float *positions, const float *directions, const float *ups, ' \
           'const float *colors, const float *scales)'
    extern 'void gr3_setobjectid(int id)'
    extern 'int gr3_selectid(int x, int y, int width, int height, int *selection_id)'
    extern 'void gr3_getviewmatrix(float *m)'
    extern 'void gr3_setviewmatrix(const float *m)'
    extern 'int gr3_getprojectiontype(void)'
    extern 'void gr3_setprojectiontype(int type)'
    # extern 'unsigned int gr3_triangulate(const unsigned short *data, unsigned short isolevel, unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, double step_x, double step_y, double step_z, double offset_x, double offset_y, double offset_z, gr3_triangle_t **triangles_p)'
    # extern 'void gr3_triangulateindexed(const unsigned short *data, unsigned short isolevel, unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, double step_x, double step_y, double step_z, double offset_x, double offset_y, double offset_z, unsigned int *num_vertices, gr3_coord_t **vertices, gr3_coord_t **normals, unsigned int *num_indices, unsigned int **indices)'
    extern 'int gr3_createisosurfacemesh(int *mesh, unsigned short *data, ' \
           'unsigned short isolevel, unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    extern 'int gr3_createsurfacemesh(int *mesh, int nx, int ny, ' \
           'float *px, float *py, float *pz, int option)'
    extern 'void gr3_drawmesh_grlike(int mesh, int n, ' \
           'const float *positions, const float *directions, const float *ups, ' \
           'const float *colors, const float *scales)'
    extern 'void gr3_drawsurface(int mesh)'
    extern 'void gr3_surface(int nx, int ny, float *px, float *py, float *pz, int option)'
    extern 'int gr3_drawtubemesh(int n, float *points, float *colors, float *radii, ' \
           'int num_steps, int num_segments)'
    extern 'int gr3_createtubemesh(int *mesh, int n, ' \
           'const float *points, const float *colors, const float *radii, ' \
           'int num_steps, int num_segments)'
    extern 'void gr3_drawspins(int n, const float *positions, const float *directions, const float *colors, ' \
           'float cone_radius, float cylinder_radius, float cone_height, float cylinder_height)'
    extern 'void gr3_drawmolecule(int n, const float *positions, const float *colors, const float *radii, ' \
           'float bond_radius, const float bond_color[3], float bond_delta)'
    extern 'void gr3_createxslicemesh(int *mesh, const unsigned short *data, ' \
           'unsigned int ix, unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    extern 'void gr3_createyslicemesh(int *mesh, const unsigned short *data, ' \
           'unsigned int iy, unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    extern 'void gr3_createzslicemesh(int *mesh, const unsigned short *data, ' \
           'unsigned int iz, unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    extern 'void gr3_drawxslicemesh(const unsigned short *data, unsigned int ix,' \
           'unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    extern 'void gr3_drawyslicemesh(const unsigned short *data, unsigned int iy, ' \
           'unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    extern 'void gr3_drawzslicemesh(const unsigned short *data, unsigned int iz, ' \
           'unsigned int dim_x, unsigned int dim_y, unsigned int dim_z, ' \
           'unsigned int stride_x, unsigned int stride_y, unsigned int stride_z, ' \
           'double step_x, double step_y, double step_z, ' \
           'double offset_x, double offset_y, double offset_z)'
    # extern 'void gr3_drawtrianglesurface(int n, const float *triangles)'
    extern 'void gr_volume(int nx, int ny, int nz, double *data, ' \
           'int algorithm, double *dmin_ptr, double *dmax_ptr)'
  end
end
