# frozen_string_literal: true

require 'ffi'
require_relative 'gr_commons'

module GR3
  class << self
    attr_reader :ffi_lib
  end

  gr3_lib_name = "libGR3.#{::FFI::Platform::LIBSUFFIX}"
  if ENV['GRDIR']
    gr3_lib = File.expand_path("lib/#{gr3_lib_name}", ENV['GRDIR'])
    ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
    @ffi_lib = gr3_lib
  else
    raise 'Please set env variable GRDIR'
  end
end

require_relative 'gr_commons'
require 'gr3/ffi'
require 'gr3/gr3base'

module GR3
  extend GR3Base
end
