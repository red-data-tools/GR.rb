# frozen_string_literal: true

# https://gr-framework.org/c.html
require 'gr/plot'

2000.times do |i|
  z = Array.new(i + 1) { |j| j / 100.0 }
  x = Array.new(i + 1) { |j| j**2 * Math.sin(j * Math::PI / 10.0) / 100.0 }
  y = Array.new(i + 1) { |j| j**2 * Math.cos(j * Math::PI / 10.0) / 100.0 }

  GR.lineplot3(x, y, z, title: "i = #{i}") # method name might be changed in the future. 
  GR.updatews
  sleep 0.005
end
gets
