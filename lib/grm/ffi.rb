# frozen_string_literal: true

require 'fiddle/import'

module GRM
  # FFI Wrapper module for GRM.
  # The functions for GRM are listed here.
  # Add functions here when a new version of GR is released.
  module FFI
    extend Fiddle::Importer

    begin
      dlload GRM.ffi_lib
    rescue LoadError
      raise LoadError, 'Could not find GR Framework'
    end

    extend GRCommons::TryExtern

    # Currently, the declarations of GRM functions are distributed in several
    # header files.

    # https://github.com/sciapp/gr/blob/master/lib/grm/args.h
    try_extern 'grm_args_t *grm_args_new(void)'
    try_extern 'void grm_args_delete(grm_args_t *args)'
    try_extern 'int grm_args_push(grm_args_t *args, const char *key, const char *value_format, ...)'
    try_extern 'int grm_args_push_buf(grm_args_t *args, const char *key, const char *value_format, const void *buffer, int apply_padding)'
    try_extern 'int grm_args_contains(const grm_args_t *args, const char *keyword)'
    try_extern 'void grm_args_clear(grm_args_t *args)'
    try_extern 'void grm_args_remove(grm_args_t *args, const char *key)'
    typealias 'grm_args_ptr_t', 'void*'
    try_extern 'grm_args_ptr_t grm_length(double value, const char *unit)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/dump.h
    try_extern 'void grm_dump(const grm_args_t *args, FILE *f)'
    try_extern 'void grm_dump_json(const grm_args_t *args, FILE *f)'
    try_extern 'char *grm_dump_json_str(void)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/event.h
    typealias 'grm_event_type_t', 'int' # enum
    typealias 'grm_event_callback_t', 'void*'
    try_extern 'int grm_register(grm_event_type_t type, grm_event_callback_t callback)'
    try_extern 'int grm_unregister(grm_event_type_t type)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/interaction.h
    # FIXME: https://github.com/ruby/fiddle/issues/68
    typealias 'const_int', 'int' # FIXME
    try_extern 'int grm_input(const grm_args_t *input_args)'
    try_extern 'int grm_get_box(const_int x1, const_int y1, const_int x2, const_int y2, const_int keep_aspect_ratio, int *x, int *y, int *w, int *h)' # FIXME
    try_extern 'int grm_is3d(const int x, const int y)'
    try_extern 'grm_tooltip_info_t *grm_get_tooltip(const_int, const_int)' # FIXME

    # https://github.com/sciapp/gr/blob/master/lib/grm/net.h
    try_extern 'void *grm_open(int is_receiver, const char *name, unsigned int id,
                               const char *(*custom_recv)(const char *, unsigned int),
                               int (*custom_send)(const char *, unsigned int, const char *))'
    try_extern 'grm_args_t *grm_recv(const void *p, grm_args_t *args)'
    try_extern 'int grm_send(const void *p, const char *data_desc, ...)'
    try_extern 'int grm_send_buf(const void *p, const char *data_desc, const void *buffer, int apply_padding)'
    try_extern 'int grm_send_ref(const void *p, const char *key, char format, const void *ref, int len)'
    try_extern 'int grm_send_args(const void *p, const grm_args_t *args)'
    try_extern 'void grm_close(const void *p)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/plot.h
    try_extern 'void grm_finalize(void)'
    try_extern 'int grm_clear(void)'
    try_extern 'unsigned int grm_max_plotid(void)'
    try_extern 'int grm_merge(const grm_args_t *args)'
    try_extern 'int grm_merge_extended(const grm_args_t *args, int hold, const char *identificator)'
    try_extern 'int grm_merge_hold(const grm_args_t *args)'
    try_extern 'int grm_merge_named(const grm_args_t *args, const char *identificator)'
    try_extern 'int grm_plot(const grm_args_t *args)'
    try_extern 'int grm_switch(unsigned int id)'
  end
end
