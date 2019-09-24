# frozen_string_literal: true

module GR
  class GR3
    # Define GR::FFI methods dynamically
    # GRBase is a private class.
    module GR3Module
      gr3_methods = FFI.public_methods.select do |gr3_method|
        gr3_method.to_s.start_with? 'gr3_'
      end

      # define method
      gr3_methods.each do |gr3_method|
        ruby_method = gr3_method.to_s.delete_prefix('gr3_')
        define_method(ruby_method) do |*args|
          FFI.send(gr3_method, *args)
        end
      end
    end
    private_constant :GR3Module
  end
end
