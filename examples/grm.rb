# frozen_string_literal: true

# Original code
# https://github.com/sciapp/gr/issues/114#issuecomment-619824616
# Written in Ruby by @kou

require 'grm'

n = 1000
x = n.times.map { |i| i * 30.0 / n }
y = n.times.map { |i| Math.cos(x[i]) * x[i] }
z = n.times.map { |i| Math.sin(x[i]) * x[i] }

GRM.plot(kind: "plot3",
         x: x,
         y: y,
         z: z)
gets
