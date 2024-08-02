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
  platform = RbConfig::CONFIG['host_os']
  lib_names, pkg_name = \
    case platform
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      [['libGRM.dll'], 'grm']
    when /darwin|mac os/
      ENV['GKSwstype'] ||= 'gksqt'
      [['libGRM.dylib', 'libGRM.so'], 'grm']
    else
      [['libGRM.so'], 'grm']
    end

  # On Windows + RubyInstaller,
  # the environment variable GKS_FONTPATH will be set.
  lib_path = GRCommons::GRLib.search(lib_names, pkg_name)

  raise NotFoundError, "#{lib_names} not found" if lib_path.nil?

  self.ffi_lib = lib_path

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
        else
          nil
        end
      end
    end

    def initialize(**args)
      @args = GRM.args_new
      @args.free = FFI["grm_args_delete"]
      @references = []
      args.each do |key, value|
        push(key, value)
      end
    end

    def push(key, value)
      key = key.to_s if key.is_a?(Symbol)
      case value
      when String
        GRM.args_push(@args, key, "s", :const_string, value)
      when Integer
        GRM.args_push(@args, key, "i", :int, value)
      when Float
        GRM.args_push(@args, key, "d", :double, value)
      when Args
        GRM.args_push(@args, key, "a", :voidp, value.address)
        value.to_gr.free = nil
      when Array
        case value[0]
        when String
          addresses = value.collect {|v| Fiddle::Pointer[v].to_i}
          GRM.args_push(@args, key, "nS",
                        :int, value.size,
                        :voidp, addresses.pack("J*"))
        when Integer
          GRM.args_push(@args, key, "nI",
                        :int, value.size,
                        :voidp, value.pack("i*"))
        when Float
          GRM.args_push(@args, key, "nD",
                        :int, value.size,
                        :voidp, value.pack("d*"))
        when Args
          GRM.args_push(@args, key, "nA",
                        :int, value.size,
                        :voidp, value.collect(&:address).pack("J*"))
          value.each do |v|
            v.to_gr.free = nil
          end
        else
          vs = value.collect {|v| Args.new(**v)}
          @references.concat(vs)
          GRM.args_push(@args, key, "nA",
                        :int, value.size,
                        :voidp, vs.collect(&:address).pack("J*"))
          vs.each do |v|
            v.to_gr.free = nil
          end
        end
      else
        v = Args.new(**value)
        @references << v
        GRM.args_push(@args, key, "a", :voidp, v.address)
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
    def merge(args=nil)
      super(Args.try_convert(args) || args)
    end

    def merge_extended(args=nil, hold=0, identifiator=nil)
      super(Args.try_convert(args) || args, hold, identificator)
    end

    def merge_hold(args=nil)
      super(Args.try_convert(args) || args)
    end

    def merge_named(args=nil, identifiator=nil)
      super(Args.try_convert(args) || args, identificator)
    end

    def plot(args=nil)
      super(Args.try_convert(args) || args)
    end
  end
end
