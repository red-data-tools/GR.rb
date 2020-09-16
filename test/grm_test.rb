# frozen_string_literal: true

require_relative 'test_helper'

class GRMTest < Test::Unit::TestCase
  class << self
    def fiddle_supports_variadic_functions?
      Fiddle.const_defined?(:VERSION) &&
        (Gem::Version.new(Fiddle::VERSION) > Gem::Version.new('1.0.0'))
    end

    def startup
      require('grm') if fiddle_supports_variadic_functions?
    end
  end

  setup
  def check_fiddle
    omit_unless GRMTest.fiddle_supports_variadic_functions?
  end

  def test_grm_ffi_lib
    assert_kind_of(String, GRM.ffi_lib)
  end

  def test_version
    assert_kind_of(String, GRM::VERSION)
  end
end
