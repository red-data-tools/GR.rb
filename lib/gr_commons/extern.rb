# frozen_string_literal: true

module GRCommons
  # This module records the names of the methods defined by Fiddle::Importer.
  module Extern
    attr_reader :ffi_methods

    # 1. Ignore functions that cannot be attached.
    #    For compatiblity with older versions of GR.
    # 2. Available function (names) are stored in @ffi_methods.
    def try_extern(signature, *opts)
      @ffi_methods ||= []
      begin
        func = extern(signature, *opts)
        @ffi_methods << func.name
        func
      rescue StandardError => e
        warn "#{e.class.name}: #{e.message}"
      end
    end
  end
end
