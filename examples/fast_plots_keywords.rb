# frozen_string_literal: true

require 'gr/plot'
require 'numo/narray'

x = Numo::DFloat.linspace(0, 10, 1001)
y = Numo::NMath.sin(x)

def s
  sleep 0.5
end

GR.lineplot(x, y)
s
GR.lineplot(x, y, title: 'Sine wave')
s
GR.lineplot(x, y, title: 'Sine wave', xlabel: 'X Label')
s
GR.lineplot(x, y, title: 'Sine wave', ylabel: 'Y Label')
s
GR.lineplot(x, y, title: 'Sine wave', xlabel: 'X Label', ylabel: 'Y Label')
s
GR.lineplot(x, y, title: 'Sine wave', backgroundcolor: 100)
s
GR.lineplot(x, y, title: 'Sine wave', alpha: 0.5)
s
GR.lineplot(x, y, title: 'Sine wave', figsize: [8, 4], alpha: 1)
s
GR.lineplot(x, y, title: 'Sine wave', size: [360, 280])
s
GR.lineplot(x, y, title: 'SIN WAVE', labels: ['Sine wave'])
s

14.times do |loc|
  GR.lineplot(x, y, title: 'SIN WAVE',
                    xlabel: 'X Label', ylabel: 'Y Label',
                    labels: ["location #{loc}"],
                    location: loc)
  s
end

10.times do |i|
  GR.lineplot(x, y, title: 'Sine wave',
                    xlim: [i, i + 1],
                    labels: ["xlim: [#{i}, #{i + 1}]"])
  s
end

5.times do |i|
  GR.lineplot(x, y, title: 'Sine wave',
                    ylim: [-9 + 2 * i, 9 - 2 * i],
                    labels: ["ylim: [#{-9 + 2 * i}, #{9 - 2 * i}]"])
  s
end

x = Numo::DFloat.linspace(0, 10, 11)
y = Numo::NMath.sin(x)

GR.stepplot(x, y, title: 'STEP')
s
%w[pre mid post].each do |w|
  GR.stepplot(x, y, title: 'STEP', where: w, labels: [w])
  s
end

data = File.readlines(File.expand_path('fecr.dat', __dir__)).map(&:to_f)
z = Numo::DFloat.cast(data).reshape(200, 200)
GR.contourfplot(z)
s
GR.contourfplot(z, xlog: true, labels: ['xlog: true'])
s
GR.contourfplot(z, ylog: true, labels: ['ylog: true'])
s
