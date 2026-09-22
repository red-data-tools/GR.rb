#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'utils'
require 'diffy'

Dir.chdir(__dir__)

gr_h_url = 'https://raw.githubusercontent.com/sciapp/gr/master/lib/gr/gr.h'
gr_h = extract_api(gr_h_url, 'DLLEXPORT')
gr_ffi = extract_ffi('../lib/gr/ffi.rb')

puts Diffy::Diff.new(gr_h, gr_ffi, context: 2).to_s(:color)
