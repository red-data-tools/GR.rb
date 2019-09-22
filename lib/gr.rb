# frozen_string_literal: true

require 'ffi'

module GR
  class << self
    attr_reader :gr_ffi_lib
  end

  gr_lib_name = "libGR.#{::FFI::Platform::LIBSUFFIX}"
  if ENV['GRDIR']
    gr_lib = File.expand_path("lib/#{gr_lib_name}", ENV['GRDIR'])
    ENV['GKS_FONTPATH'] ||= ENV['GRDIR']
    @gr_ffi_lib = gr_lib
  else
    raise 'Please set env variable GRDIR'
  end
end

require 'gr/ffi'
require 'gr/gr'
require 'gr/version'
