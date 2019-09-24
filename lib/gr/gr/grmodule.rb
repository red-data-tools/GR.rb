# frozen_string_literal: true

module GR
  class GR
    # Define GR::FFI methods dynamically
    # GRBase is a private class.
    module GRModule
      gr_methods = FFI.public_methods.select do |gr_method|
        gr_method.to_s.start_with? 'gr_'
      end

      # define method
      gr_methods.each do |gr_method|
        ruby_method = gr_method.to_s.delete_prefix('gr_')
        define_method(ruby_method) do |*args|
          FFI.send(gr_method, *args)
        end
      end
    end
    private_constant :GRModule
  end
end
