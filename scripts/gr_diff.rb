#!/usr/bin/env ruby

require_relative 'utils'
require 'diffy'

gr_h = extract_api('https://raw.githubusercontent.com/sciapp/gr/master/lib/gr/gr.h', 'DLLEXPORT')
gr_ffi = extract_ffi('../lib/gr/ffi.rb')

puts Diffy::Diff.new(gr_h, gr_ffi, context: 2).to_s(:color)
