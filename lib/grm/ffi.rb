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

    extend GRCommons::Extern

    # Currently, the declarations of GRM functions are distributed in several
    # header files.

    # https://github.com/sciapp/gr/blob/master/lib/grm/args.h

    try_extern 'grm_args_t *grm_args_new(void)'
    try_extern 'void grm_args_delete(grm_args_t *args)'
    # Fiddle does not currently support variable-length arguments in C.
    try_extern 'int grm_args_push(grm_args_t *args, const char *key, const char *value_format, ...)'
    try_extern 'int grm_args_push_buf(grm_args_t *args, const char *key, const char *value_format, const void *buffer, int apply_padding)'
    try_extern 'int grm_args_contains(const grm_args_t *args, const char *keyword)'
    try_extern 'void grm_args_clear(grm_args_t *args)'
    try_extern 'void grm_args_remove(grm_args_t *args, const char *key)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/dump.h
    try_extern 'void grm_dump(const grm_args_t *args, FILE *f)'
    try_extern 'void grm_dump_json(const grm_args_t *args, FILE *f)'
    try_extern 'char *grm_dump_json_str(void)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/event.h
    # grm_event_type_t is an enum.
    # In the original fiddley, there is code for an enum.
    # But GR's fiddley doesn't have it.
    # try_extern 'int grm_register(grm_event_type_t type, grm_event_callback_t callback)'
    # try_extern 'int grm_unregister(grm_event_type_t type)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/interaction.h
    try_extern 'int grm_input(const grm_args_t *input_args)'
    # try_extern 'int grm_get_box(const int x1, const int y1, const int x2, const int y2, const int keep_aspect_ratio, int *x, int *y, int *w, int *h)'
    # try_extern 'grm_tooltip_info_t *grm_get_tooltip(const int, const int)'

    # https://github.com/sciapp/gr/blob/master/lib/grm/net.h
    # try_extern 'void *grm_open(int is_receiver, const char *name, unsigned int id,
    #                            const char *(*custom_recv)(const char *, unsigned int),
    #                            int (*custom_send)(const char *, unsigned int, const char *))
    try_extern 'grm_args_t *grm_recv(const void *p, grm_args_t *args)'
    # Fiddle does not currently support variable-length arguments in C.
    try_extern 'int grm_send(const void *p, const char *data_desc, ...)'
    try_extern 'int grm_send_buf(const void *p, const char *data_desc, const void *buffer, int apply_padding)'
    try_extern 'int grm_send_ref(const void *p, const char *key, char format, const void *ref, int len)'
    try_extern 'int grm_send_args(const void *p, const grm_args_t *args)'
    try_extern 'void grm_close(const void *p)'
  end
end
