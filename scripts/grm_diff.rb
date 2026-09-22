#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'utils'
require 'diffy'

Dir.chdir(__dir__)

base_url = 'https://raw.githubusercontent.com/sciapp/gr/master/lib/grm/include/grm'
headers = %w[
  args.h
  dump.h
  event.h
  interaction.h
  net.h
  plot.h
]

grm_h = headers.map { extract_api("#{base_url}/#{_1}", 'EXPORT', c_only: true) }.join
grm_ffi = extract_ffi('../lib/grm/ffi.rb')

puts Diffy::Diff.new(grm_h, grm_ffi, context: 2).to_s(:color)
