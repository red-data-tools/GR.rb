# frozen_string_literal: true

module GRCommons
  # This module modifies the behavior of the extern method.
  module Extern
    # Remember added method name
    def extern(*args)
      @ffi_methods ||= []
      func = super(*args)
      @ffi_methods << func.name
      func
    end

    attr_reader :ffi_methods
  end
end
