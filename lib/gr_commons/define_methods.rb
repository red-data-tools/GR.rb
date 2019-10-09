# frozen_string_literal: true

module GRCommons
  module DefineMethods
    private

    def define_ffi_methods(ffi_class, prefix)
      ffi_class.ffi_methods.each do |method|
        # delete_prefix (Ruby >= 2.5)
        method_name = method.to_s.sub(/^#{prefix}/, '')

        define_method(method_name) do |*args|
          args.map! do |arg|
            case arg
            when Array
              double(arg)
            when ->(x) { narray? x }
              double(arg)
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
