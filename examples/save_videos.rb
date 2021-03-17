# frozen_string_literal: true

# ENV["GKS_WSTYPE"] = "mp4"
# ENV["GKS_VIDEO_OPTS"] = "600x450@25@2x" # video size

require 'gr/plot'
require 'fileutils'

Dir.chdir(__dir__)
FileUtils.mkdir_p 'savefig'

x = []
y = []
z = []

2000.times do |i|
  z <<  i / 100.0
  x <<  i**2 * Math.sin(i * Math::PI / 10.0) / 100.0
  y <<  i**2 * Math.cos(i * Math::PI / 10.0) / 100.0
end

GR.beginprint('savefig/video.mov')

2000.times do |i|
  GR.plot3(x[0..i], y[0..i], z[0..i], title: "i = #{i}")
  GR.updatews
end

GR.endprint

GR.beginprint('savefig/video.mp4')

2000.times do |j|
  i = 1999 - j
  GR.plot3(x[0..i], y[0..i], z[0..i], title: "i = #{i}")
  GR.updatews
end

GR.endprint
