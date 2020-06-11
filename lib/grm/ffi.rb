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

  end
end
