# frozen_string_literal: true

module GRCommons
  # This module records the names of the methods defined by Fiddle::Importer.
  module TryExtern
    attr_reader :ffi_methods

    # Improved extern method.
    # 1. Ignore functions that cannot be attached.
    # 2. Available function (names) are stored in @ffi_methods.
    # For compatibility with older versions of GR.
    def try_extern(signature, *opts)
      @ffi_methods ||= []
      begin
        func = extern(signature, *opts)
        @ffi_methods << func.name
        func
      rescue Fiddle::DLError => e
        warn "#{e.class.name}: #{e.message}" if $VERBOSE
      end
    end
  end
end
