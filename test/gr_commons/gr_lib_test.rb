# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/gr_commons/gr_commons'
require 'fileutils'
require 'tmpdir'

class GRCommonsGRLibTest < Test::Unit::TestCase
  def test_default_lib_names
    expected =
      case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        ['libGR.dll']
      when /darwin|mac os/
        ['libGR.dylib', 'libGR.so']
      else
        ['libGR.so']
      end

    assert_equal expected, GRCommons::GRLib.default_lib_names('gr')
  end

  def test_load_library
    original_grdir = ENV['GRDIR']
    Dir.mktmpdir do |dir|
      lib_path = File.join(dir, 'libGR.so')
      FileUtils.touch(lib_path)
      mod = Module.new do
        class << self
          attr_accessor :ffi_lib
        end
      end

      ENV['GRDIR'] = dir
      GRCommons::GRLib.load_library(
        mod,
        pkg_name: 'gr',
        lib_names: ['libGR.so'],
        not_found_error: RuntimeError
      )

      assert_equal File.realpath(lib_path), File.realpath(mod.ffi_lib)
    end
  ensure
    ENV['GRDIR'] = original_grdir
  end

  def test_recursive_search
    assert_kind_of String,
                   GRCommons::GRLib.recursive_search(
                     'gr.rb',
                     File.expand_path('../../', __dir__)
                   )
  end

  def test_recursive_search_multiple_hit
    stderr = $stderr.dup
    require 'stringio'
    $stderr = StringIO.new(s = String.new(''))
    assert_kind_of String,
                   GRCommons::GRLib.recursive_search(
                     'ffi.rb',
                     File.expand_path('../../', __dir__)
                   )
    assert_equal "More than one file found: [\"lib/gr/ffi.rb\", \"lib/gr3/ffi.rb\", \"lib/grm/ffi.rb\"]\n", s
    $stderr = stderr
  end

  def test_recursive_search_not_found
    assert_equal nil,
                 GRCommons::GRLib.recursive_search(
                   'jheinen.jl',
                   File.expand_path('../../', __dir__)
                 )
  end
end
