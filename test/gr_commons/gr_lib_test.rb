# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/gr_commons/gr_commons'

class GRCommonsGRLibTest < Test::Unit::TestCase
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
