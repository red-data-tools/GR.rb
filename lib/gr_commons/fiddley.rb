# frozen_string_literal: true

# https://github.com/unak/fiddley
# unak/fiddley
# Copyright (c) 2017 NAKAMURA Usaku usa@garbagecollect.jp

require 'fiddle/import'

module Fiddley
  # unpack1 Ruby 2.4
  unless ''.respond_to?(:unpack1)
    module RefineStringUnpack1
      refine String do
        def unpack1(arg)
          unpack(arg).first
        end
      end
    end

    using RefineStringUnpack1
  end

  module Utils
    # assumes short = 16bit, int = 32bit, long long = 64bit
    SIZET_FORMAT = Fiddle::SIZEOF_VOIDP == Fiddle::SIZEOF_LONG ? 'l!' : 'q'
    SIZET_TYPE = Fiddle::SIZEOF_VOIDP == Fiddle::SIZEOF_LONG ? 'unsigned long' : 'unsigned long long'

    module_function def type2size(type)
      case type
      when :char, :uchar, :int8, :uint8
        Fiddle::SIZEOF_CHAR
      when :short, :ushort, :int16, :uint16
        Fiddle::SIZEOF_SHORT
      when :int, :uint, :int32, :uint32, :bool
        Fiddle::SIZEOF_INT
      when :long, :ulong
        Fiddle::SIZEOF_LONG
      when :int64, :uint64, :long_long, :ulong_long
        Fiddle::SIZEOF_LONG_LONG
      when :float
        Fiddle::SIZEOF_FLOAT
      when :double
        Fiddle::SIZEOF_DOUBLE
      when :size_t
        Fiddle::SIZEOF_SIZE_T
      when :string, :pointer
        Fiddle::SIZEOF_VOIDP
      else
        raise "unknown type #{type}"
      end
    end

    module_function def type2offset_size(type)
      case type
      when :char, :uchar, :int8, :uint8
        Fiddle::ALIGN_CHAR
      when :short, :ushort, :int16, :uint16
        Fiddle::ALIGN_SHORT
      when :int, :uint, :int32, :uint32, :bool
        Fiddle::ALIGN_INT
      when :long, :ulong
        Fiddle::ALIGN_LONG
      when :int64, :uint64, :long_long, :ulong_long
        Fiddle::ALIGN_LONG_LONG
      when :float
        Fiddle::ALIGN_FLOAT
      when :double
        Fiddle::ALIGN_DOUBLE
      when :size_t
        Fiddle::ALIGN_SIZE_T
      when :string, :pointer
        Fiddle::ALIGN_VOIDP
      else
        raise "unknown type #{type}"
      end
    end

    module_function def str2value(type, str)
      case type
      when :char, :int8
        str.unpack1('c')
      when :uchar, :uint8
        str.unpack1('C')
      when :short, :int16
        str.unpack1('s')
      when :ushort, :uint16
        str.unpack1('S')
      when :int32
        str.unpack1('l')
      when :uint32
        str.unpack1('L')
      when :int
        str.unpack1('i!')
      when :uint
        str.unpack1('I!')
      when :bool
        str.unpack1('i!') != 0
      when :long
        str.unpack1('l!')
      when :ulong
        str.unpack1('L!')
      when :long_long, :int64
        str.unpack1('q')
      when :ulong_long, :uint64
        str.unpack1('Q')
      when :size_t
        str.unpack1(SIZET_FORMAT)
      when :float
        str.unpack1('f')
      when :double
        str.unpack1('d')
      when :string, :pointer
        str.unpack1('p')
      else
        raise "unknown type #{type}"
      end
    end

    module_function def str2array(type, str)
      case type
      when :char, :int8
        str.unpack('c*')
      when :uchar, :uint8
        str.unpack('C*')
      when :short, :int16
        str.unpack('s*')
      when :ushort, :uint16
        str.unpack('S*')
      when :int32
        str.unpack('l*')
      when :uint32
        str.unpack('L*')
      when :int
        str.unpack('i!*')
      when :uint
        str.unpack('I!*')
      when :bool
        str.unpack('i!*') != 0
      when :long
        str.unpack('l!*')
      when :ulong
        str.unpack('L!*')
      when :long_long, :int64
        str.unpack('q*')
      when :ulong_long, :uint64
        str.unpack('Q*')
      when :size_t
        str.unpack(SIZET_FORMAT)
      when :float
        str.unpack('f*')
      when :double
        str.unpack('d*')
      when :string, :pointer
        str.unpack('p*')
      else
        raise "unknown type #{type}"
      end
  end

    module_function def value2str(type, value)
      case type
      when :char, :int8
        [value].pack('c')
      when :uchar, :uint8
        [value].pack('C')
      when :short, :int16
        [value].pack('s')
      when :ushort, :uint16
        [value].pack('S')
      when :int32
        [value].pack('l')
      when :uint32
        [value].pack('L')
      when :int
        [value].pack('i!')
      when :uint
        [value].pack('I!')
      when :bool
        [value ? 1 : 0].pack('i!')
      when :long
        [value].pack('l!')
      when :ulong
        [value].pack('L!')
      when :long_long, :int64
        [value].pack('q')
      when :ulong_long, :uint64
        [value].pack('Q')
      when :size_t
        [value].pack(SIZET_FORMAT)
      when :float
        [value].pack('f')
      when :double
        [value].pack('d')
      when :string, :pointer
        [value].pack('p')
      else
        raise "unknown type #{type}"
      end
    end

    # add
    module_function def array2str(type, arr)
      case type
      when :char, :int8
        arr.pack('c*')
      when :uchar, :uint8
        arr.pack('C*')
      when :short, :int16
        arr.pack('s*')
      when :ushort, :uint16
        arr.pack('S*')
      when :int32
        arr.pack('l*')
      when :uint32
        arr.pack('L*')
      when :int
        arr.pack('i!*')
      when :uint
        arr.pack('I!*')
      when :bool
        [arr ? 1 : 0].pack('i!*')
      when :long
        arr.pack('l!*')
      when :ulong
        arr.pack('L!*')
      when :long_long, :int64
        arr.pack('q*')
      when :ulong_long, :uint64
        arr.pack('Q*')
      when :size_t
        arr.pack(SIZET_FORMAT)
      when :float
        arr.pack('f*')
      when :double
        arr.pack('d*')
      when :string, :pointer
        arr.pack('p*')
      else
        raise "unknown type #{type}"
      end
  end

    module_function def type2str(type)
      case type
      when :char, :int8
        'char'
      when :uchar, :uint8
        'unsigned char'
      when :short, :int16
        'short'
      when :ushort, :uint16
        'unsigned short'
      when :int, :int32
        'int'
      when :uint, :uint32
        'unsigned int'
      when :bool
        'int'
      when :long
        'long'
      when :ulong
        'unsigned long'
      when :long_long, :int64
        'long long'
      when :ulong_long, :uint64
        'unsigned long long'
      when :size_t
        SIZET_TYPE
      when :float
        'float'
      when :double
        'double'
      when :string, :pointer
        'void *'
      else
        if @enums && @enums.find { |e| type == e.tag }
          'int'
        else
          type.to_s
        end
      end
    end

    module_function def type2type(type)
      case type
      when :char, :int8
        Fiddle::TYPE_CHAR
      when :uchar, :uint8
        -Fiddle::TYPE_CHAR
      when :short, :int16
        Fiddle::TYPE_SHORT
      when :ushort, :uint16
        -Fiddle::TYPE_SHORT
      when :int, :int32
        Fiddle::TYPE_INT
      when :uint, :uint32
        -Fiddle::TYPE_INT
      when :bool
        Fiddle::TYPE_INT
      when :long
        Fiddle::TYPE_LONG
      when :ulong
        -Fiddle::TYPE_LONG
      when :long_long, :int64
        Fiddle::TYPE_LONG_LONG
      when :ulong_long, :uint64
        -Fiddle::TYPE_LONG_LONG
      when :float
        Fiddle::TYPE_FLOAT
      when :double
        Fiddle::TYPE_DOUBLE
      when :size_t
        Fiddle::TYPE_SIZE_T
      when :string, :pointer
        Fiddle::TYPE_VOIDP
      when :void
        Fiddle::TYPE_VOID
      else
        raise "unknown type #{type}"
      end
    end
  end

  class MemoryPointer
    using Fiddley::RefineStringUnpack1 if defined?(Fiddley::RefineStringUnpack1)

    include Fiddley::Utils

    def initialize(type, num = 1, _clear = true)
      if num.is_a?(Fiddle::Pointer)
        @ptr = num
        @size = @ptr.size
      else
        @size = type2size(type) * num
        @ptr = Fiddle::Pointer.malloc(@size)
      end
    end

    attr_reader :size

    def to_ptr
      @ptr
    end

    { 8 => 'c', 16 => 's', 32 => 'l', 64 => 'q' }.each_pair do |bits, form|
      bytes = bits / 8

      define_method("put_int#{bits}") do |offset, val|
        @ptr[offset, bytes] = [val].pack(form)
      end

      define_method("write_int#{bits}") do |val|
        __send__("put_int#{bits}", 0, val)
      end

      define_method("put_array_of_int#{bits}") do |offset, ary|
        put_bytes(offset, ary.pack(form + '*'))
      end

      define_method("write_array_of_int#{bits}") do |ary|
        __send__("put_array_of_int#{bits}", 0, ary)
      end

      define_method("get_int#{bits}") do |offset|
        @ptr[offset, bytes].unpack1(form)
      end

      define_method("read_int#{bits}") do
        __send__("get_int#{bits}", 0)
      end

      define_method("get_array_of_int#{bits}") do |offset, num|
        @ptr[offset, bytes * num].unpack(form + '*')
      end

      define_method("read_array_of_int#{bits}") do |num|
        __send__("get_array_of_int#{bits}", 0, num)
      end

      form2 = form.upcase

      define_method("put_uint#{bits}") do |offset, val|
        @ptr[offset, bytes] = [val].pack(form2)
      end

      define_method("write_uint#{bits}") do |val|
        __send__("put_uint#{bits}", 0, val)
      end

      define_method("put_array_of_uint#{bits}") do |offset, ary|
        put_bytes(offset, ary.pack(form2 + '*'))
      end

      define_method("write_array_of_uint#{bits}") do |ary|
        __send__("put_array_of_uint#{bits}", 0, ary)
      end

      define_method("get_uint#{bits}") do |offset|
        @ptr[offset, bytes].unpack1(form2)
      end

      define_method("read_uint#{bits}") do
        __send__("get_uint#{bits}", 0)
      end

      define_method("get_array_of_uint#{bits}") do |offset, num|
        @ptr[offset, bytes * num].unpack(form2 + '*')
      end

      define_method("read_array_of_uint#{bits}") do |num|
        __send__("get_array_of_uint#{bits}", 0, num)
      end
    end

    # added
    define_method('put_double') do |offset, val|
      @ptr[offset, 8] = [val].pack('d')
    end

    # added
    define_method('put_float') do |offset, val|
      @ptr[offset, 4] = [val].pack('f')
    end

    # added
    define_method('write_double') do |val|
      __send__('put_double', 0, val)
    end

    # added
    define_method('write_float') do |val|
      __send__('put_float', 0, val)
    end

    # added
    define_method('put_array_of_double') do |offset, ary|
      put_bytes(offset, ary.pack('d*'))
    end

    # added
    define_method('write_array_of_double') do |ary|
      __send__('put_array_of_double', 0, ary)
    end

    # added
    define_method('put_array_of_float') do |offset, ary|
      put_bytes(offset, ary.pack('f*'))
    end

    # added
    define_method('write_array_of_float') do |ary|
      __send__('put_array_of_float', 0, ary)
    end

    # added
    define_method('get_double') do |offset|
      @ptr[offset, 8].unpack1('d')
    end

    # added
    define_method('read_double') do
      __send__('get_double', 0)
    end

    # added
    define_method('get_float') do |offset|
      @ptr[offset, 4].unpack1('f')
    end

    # added
    define_method('read_float') do
      __send__('get_double', 0)
    end

    # added
    define_method('get_array_of_double') do |offset, num|
      @ptr[offset, 8 * num].unpack('d' + '*')
    end

    # added
    define_method('get_array_of_float') do |offset, num|
      @ptr[offset, 4 * num].unpack('f' + '*')
    end

    # added
    define_method('read_array_of_double') do |num|
      __send__('get_array_of_double', 0, num)
    end

    # added
    define_method('read_array_of_float') do |num|
      __send__('get_array_of_float', 0, num)
    end

    def put_bytes(offset, str, idx = 0, len = str.bytesize - idx)
      @ptr[offset, len] = str[idx, len]
    end

    def write_bytes(str, idx = 0, len = nil)
      put_bytes(0, str, idx, len)
    end

    def get_bytes(offset, len)
      @ptr[offset, len]
    end

    def read_bytes(len)
      get_bytes(0, len)
    end

    def put_string(offset, str)
      @ptr[offset, str.bytesize] = str
    end

    def write_string(str, len = nil)
      put_string(0, len ? str[0, len] : str)
    end

    def write_string_length(str, len)
      put_string(0, str[0, len])
    end

    def get_string(offset, len = nil)
      @ptr[offset, len || @size - offset]
    end

    def read_string(len = nil)
      get_string(0, len)
    end

    alias put_int put_int32
    alias write_int write_int32
    alias get_int get_int32
    alias read_int read_int32
    alias write_array_of_int write_array_of_int32 # added
    alias read_array_of_int read_array_of_int32 # added

    alias put_uint put_uint32
    alias write_uint write_uint32
    alias get_uint get_uint32
    alias read_uint read_uint32
    alias write_array_of_uint write_array_of_uint32 # added
    alias read_array_of_uint read_array_of_uint32 # added
  end

  class Function < Fiddle::Closure::BlockCaller
    include Fiddley::Utils

    def initialize(ret, params, blk)
      super(type2type(ret), params.map { |e| type2type(e) }, &blk)
    end
  end
end
