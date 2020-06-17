# frozen_string_literal: true

require_relative 'test_helper'
require 'grm'

class GRMTest < Test::Unit::TestCase
  def setup; end

  def teardown; end

  def test_grm_ffi_lib
    assert_kind_of String, GRM.ffi_lib
  end

  def test_version
    assert_kind_of String, GRM::VERSION
  end
end
