#!/usr/bin/env ruby

require_relative 'utils'
require 'diffy'

Dir.chdir(__dir__)

urls = %w[
  https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm/args.h
  https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm/dump.h
  https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm/event.h
  https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm/interaction.h
  https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm/net.h
  https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm/plot.h
]

grm_h = urls.map { extract_api(_1, 'EXPORT') }.join("\n")
grm_ffi = extract_ffi('../lib/grm/ffi.rb')

puts Diffy::Diff.new(grm_h, grm_ffi, context: 2).to_s(:color)