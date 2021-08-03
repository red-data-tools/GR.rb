# frozen_string_literal: true

# configure video
ENV['GKS_WSTYPE']     = 'mp4'
ENV['GKS_VIDEO_OPTS'] = '600x450@25@2x' # video size

require 'gr/plot'
require 'fileutils'

Dir.chdir(__dir__)
FileUtils.mkdir_p 'savefig'

epoch = 400

x = []
y = []
z = []

epoch.times do |i|
  z <<  i / 100.0
  x <<  i**2 * Math.sin(i * Math::PI / 10.0) / 100.0
  y <<  i**2 * Math.cos(i * Math::PI / 10.0) / 100.0
end

# start
GR.beginprint('savefig/video.mov')

epoch.times do |i|
  GR.plot3(x[0..i], y[0..i], z[0..i], title: "i = #{i}")
  GR.updatews
end

# stop
GR.endprint

# configure video size
ENV['GKS_VIDEO_OPTS'] = '360x240@25@2x'

# You can use block
GR.beginprint('savefig/video.mp4') do
  epoch.times do |j|
    i = epoch - j - 1
    GR.plot3(x[0..i], y[0..i], z[0..i], title: "i = #{i}")
    GR.updatews
  end
end
