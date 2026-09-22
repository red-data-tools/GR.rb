#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'utils'
require 'diffy'

Dir.chdir(__dir__)

gr3_h_url = 'https://raw.githubusercontent.com/sciapp/gr/master/lib/gr3/gr3.h'
gr3_h = extract_api(gr3_h_url, 'GR3API', c_only: true)
gr3_ffi = extract_ffi('../lib/gr3/ffi.rb')

puts Diffy::Diff.new(gr3_h, gr3_ffi, context: 2).to_s(:color)
