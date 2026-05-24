# frozen_string_literal: true

# Check Fiddle version.
require 'fiddle'

# Check if fiddle supports variadic arguments.
# Fiddle is a standard Gem and may not have VERSION constant.
if !Fiddle.const_defined?(:VERSION) ||
   (Gem::Version.new(Fiddle::VERSION) <= Gem::Version.new('1.0.0'))
  raise LoadError, <<~MSG
    Failed to load GRM module
    Fiddle 1.0.1 or higher is required to run GRM.
    See https://github.com/ruby/fiddle
  MSG
end

module GRM
  class Error < StandardError; end

  class NotFoundError < Error; end

  class << self
    attr_accessor :ffi_lib
  end

  require_relative 'gr_commons/gr_commons'

  # Platforms |  path
  # Windows   |  bin/libGRM.dll
  # MacOSX    |  lib/libGRM.dylib ( <= v0.53.0 .so)
  # Ubuntu    |  lib/libGRM.so
  # On Windows + RubyInstaller,
  # the environment variable GKS_FONTPATH will be set.
  GRCommons::GRLib.load_library(self, pkg_name: 'grm', not_found_error: NotFoundError)

  require_relative 'grm/version'
  require_relative 'grm/ffi'
  require_relative 'grm/grmbase'

  # `inquiry` methods etc. are defined here.
  extend GRCommons::GRCommonUtils

  # `XXX` is the default type in GR.
  # A Ruby array or NArray passed to GR method is automatically converted to
  # a Fiddley::MemoryPointer in the GRBase class.
  extend GRMBase

  class Args
    class << self
      def try_convert(value)
        case value
        when Hash
          new(**value)
        end
      end
    end

    def initialize(**args)
      @args = GRM.args_new
      @args.free = FFI['grm_args_delete']
      @references = []
      args.each do |key, value|
        push(key, value)
      end
    end

    def push(key, value)
      key = key.to_s if key.is_a?(Symbol)

      # Support Numo::NArray transparently when available
      if defined?(Numo::NArray) && value.is_a?(Numo::NArray)
        shape = value.shape
        case shape.length
        when 1
          # 1D NArray: delegate to existing Array handling
          return push(key, value.to_a)
        when 2
          # 2D NArray: convert to nested Array and reuse 2D Array path
          rows, cols = shape
          nested = Array.new(rows) do |r|
            Array.new(cols) do |c|
              value[r, c]
            end
          end
          return push(key, nested)
        else
          raise ArgumentError, "Numo::NArray with dimension > 2 is not supported for key '#{key}'"
        end
      end

      case value
      when String
        GRM.args_push(@args, key, 's', :const_string, value)
      when Integer
        GRM.args_push(@args, key, 'i', :int, value)
      when Float
        GRM.args_push(@args, key, 'd', :double, value)
      when TrueClass, FalseClass
        GRM.args_push(@args, key, 'i', :int, value ? 1 : 0)
      when Args
        @references << value
        GRM.args_push(@args, key, 'a', :voidp, value.address)
        value.to_gr.free = nil
      when Array
        raise ArgumentError, "Array value for key '#{key}' cannot be empty" if value.empty?

        # Handle 2D Array (Matrix): flatten and add dimensions
        if value[0].is_a?(Array)
          rows = value.size
          cols = value[0].size
          # Validate that all rows have the same length
          unless value.all? { |row| row.size == cols }
            raise ArgumentError, "All rows in 2D array for key '#{key}' must have the same length"
          end

          # Flatten in row-major order
          flattened = value.flatten

          push(key, flattened)
          # GRM expects dims in [width, height] order (columns, rows)
          push("#{key}_dims", [cols, rows])
          return
        end

        case value[0]
        when String
          addresses = value.collect { |v| Fiddle::Pointer[v].to_i }
          @references.concat(value)
          packed = addresses.pack('J*')
          @references << packed
          GRM.args_push(@args, key, 'nS',
                        :int, value.size,
                        :voidp, packed)
        when Integer, Float
          if value.all? { |v| v.is_a?(Integer) }
            packed = value.pack('i*')
            @references << packed
            GRM.args_push(@args, key, 'nI',
                          :int, value.size,
                          :voidp, packed)
            return
          end

          packed = value.map(&:to_f).pack('d*')
          @references << packed
          GRM.args_push(@args, key, 'nD',
                        :int, value.size,
                        :voidp, packed)
        when Args
          @references.concat(value)
          packed = value.collect(&:address).pack('J*')
          @references << packed
          GRM.args_push(@args, key, 'nA',
                        :int, value.size,
                        :voidp, packed)
          value.each do |v|
            v.to_gr.free = nil
          end
        else
          vs = value.collect { |v| Args.new(**v) }
          @references.concat(vs)
          packed = vs.collect(&:address).pack('J*')
          @references << packed
          GRM.args_push(@args, key, 'nA',
                        :int, value.size,
                        :voidp, packed)
          vs.each do |v|
            v.to_gr.free = nil
          end
        end
      else
        v = Args.new(**value)
        @references << v
        GRM.args_push(@args, key, 'a', :voidp, v.address)
        v.to_gr.free = nil
      end
    end

    def clear
      GRM.args_clear(@args)
      @references.clear
    end

    def address
      @args.to_i
    end

    def to_gr
      @args
    end
  end

  class << self
    def merge(args = nil)
      args = Args.try_convert(args) || args
      super(args)
    end

    def merge_extended(args = nil, hold = 0, identificator = nil)
      args = Args.try_convert(args) || args
      super(args, hold, identificator)
    end

    def merge_hold(args = nil)
      args = Args.try_convert(args) || args
      super(args)
    end

    def merge_named(args = nil, identificator = nil)
      args = Args.try_convert(args) || args
      super(args, identificator)
    end

    def plot(args = nil)
      args = Args.try_convert(args) || args
      super(args)
    end

    def export(file_path, export_xml = 0)
      super(file_path, export_xml)
    end
  end
end
