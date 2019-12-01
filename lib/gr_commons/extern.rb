# frozen_string_literal: true

module GRCommons
  # This module records the names of the methods defined by Fiddle::Importer.
  module Extern
    attr_reader :ffi_methods

    # Remember added method name
    def extern(*args)
      @ffi_methods ||= []
      func = super(*args)
      @ffi_methods << func.name
      func
    end
  end
end
