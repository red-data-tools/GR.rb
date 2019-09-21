# frozen_string_literal: true

require_relative 'test_helper'

class GRTest < Minitest::Test
  def test_version
    assert_instance_of String, GR::VERSION
  end

  def setup
    @g = GR::GR.new
  end

  def test_gr_version
    assert_instance_of String, @g.version
  end

end
