# frozen_string_literal: true

require_relative '../test_helper'
require 'gr/plot'

class PlotTest < Test::Unit::TestCase
  def setup
    @plot = GR::Plot.new
  end

  def test_minmax
    assert_equal [Float::INFINITY, -Float::INFINITY], @plot.send(:minmax, :line)
  end
end
