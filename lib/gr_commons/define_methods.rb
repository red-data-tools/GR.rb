# frozen_string_literal: true

module GRCommons
  # This module adds methods to the GRBase and GR3Base modules.
  module DefineMethods
    private

    def define_ffi_methods(ffi_class, prefix: '', default_type: :double)
      ffi_class.ffi_methods.each do |method|
        # delete_prefix (Ruby >= 2.5)
        method_name = method.to_s.sub(/^#{prefix}/, '')

        define_method(method_name) do |*args|
          args.map! do |arg|
            case arg
            when Array
              send(default_type, arg)
            when ->(x) { narray? x }
              send(default_type, arg)
            else
              arg
            end
          end
          ffi_class.send(method, *args)
        end
      end
    end
  end
end
