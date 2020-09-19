# frozen_string_literal: true

# Original code
# https://github.com/sciapp/gr/issues/114#issuecomment-619824616
# Written in Ruby by @kou

require 'grm'

n = 1000
x = n.times.map { |i| i * 30.0 / n }
y = n.times.map { |i| Math.cos(x[i]) * x[i] }
z = n.times.map { |i| Math.sin(x[i]) * x[i] }

args = GRM.args_new
GRM.args_push(args, 'kind', 's', :const_string, 'plot3')
GRM.args_push(args, 'x', 'nD', :int, n, :voidp, x.pack('d*'))
GRM.args_push(args, 'y', 'nD', :int, n, :voidp, y.pack('d*'))
GRM.args_push(args, 'z', 'nD', :int, n, :voidp, z.pack('d*'))

GRM.plot(args)

gets

GRM.args_delete(args)
