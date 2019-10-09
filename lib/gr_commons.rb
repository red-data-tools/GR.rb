# frozen_string_literal: true

module GRCommons
  module AttachFunction
    def attach_function(name, *args)
      @ffi_methods ||= []
      @ffi_methods << name
      super(name, *args)
    end

    attr_reader :ffi_methods
  end

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

  module GRCommonRule
    private

    def length(pt, dtype = :double)
      case pt
      when Array
        pt.size
      when ->(x) { narray? x }
        pt.size
      when ::FFI::MemoryPointer
        case dtype
        when :int
          pt.size / ::FFI::Type::INT.size
        when :double
          pt.size / ::FFI::Type::DOUBLE.size
        else
          raise "Unknown type: #{dtype}"
        end
      else
        raise
      end
    end

    def int(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:int, data.size)
      pt.write_array_of_int data
    end

    def double(data)
      data = data.to_a.flatten
      pt = ::FFI::MemoryPointer.new(:double, data.size)
      pt.write_array_of_double data
    end

    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end
  end

  module SupportIRuby
    # For IRuby Notebook
    if defined? IRuby
      require 'tempfile'
      ENV['GKSwstype'] = 'svg'
      @tempfile_svg = Tempfile.open(['plot', '.svg'])
      ENV['GKS_FILEPATH'] = @tempfile_svg.path
      def self.show
        emergencyclosegks
        sleep 0.5
        svg = File.read(@tempfile_svg.path)
        IRuby.display(svg, mime: 'image/svg+xml')
        nil
      end
    end
  end
end
