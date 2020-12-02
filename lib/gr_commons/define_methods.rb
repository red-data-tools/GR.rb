# frozen_string_literal: true

module GRCommons
  # This module provides a way to add FFI methods to the GRBase and GR3Base modules.
  module DefineMethods
    private

    def define_ffi_methods(ffi_module, prefix: '', default_type: :double)
      ffi_module.ffi_methods.each do |method|
        # Use delete_prefix (Ruby >= 2.5)
        method_name = method.to_s.sub(/^#{prefix}/, '')

        # FIXME: Refactoring required

        define_method(method_name) do |*args|
          args.map! do |arg|
            case arg
            when Array
              GRCommons::GRCommonUtils.public_send(default_type, arg)
            when ->(x) { defined?(Numo::NArray) && x.is_a?(Numo::NArray) }
              GRCommons::GRCommonUtils.public_send(default_type, arg)
            else
              arg
            end
          end
          ffi_module.public_send(method, *args)
        end
      end
    end
  end
end
