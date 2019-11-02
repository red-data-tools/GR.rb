# frozen_string_literal: true

require 'gr'
require 'numo/narray'

def mandel(c, iters)
  output = Numo::UInt8.zeros(c.shape)
  z = Numo::DComplex.zeros(c.shape)
  iters.times do |i|
    notdone = (z.real * z.real + z.imag * z.imag < 4.0)
    output[notdone] = i
    z[notdone] = z[notdone]**2 + c[notdone]
  end
  output[output.eq(iters - 1)] = 0
  output
end

def create_fractal(min_x, max_x, min_y, max_y, image, iters)
  height = image.shape[0]
  width = image.shape[1]

  r1 = Numo::DFloat.linspace(min_x, max_x, width)
  r2 = Numo::DFloat.linspace(min_y, max_y, height)
  c = r1 + r2.expand_dims(1) * Complex('1.0i')
  mandel(c, iters).transpose
end

x = -0.9223327810370947027656057193752719757635
y = 0.3102598350874576432708737495917724836010

f = 0.5

100.times do
  start = Time.now
  image = Numo::UInt8.zeros(500, 500)
  pixels = create_fractal(x - f, x + f, y - f, y + f, image, 400)
  dt = Time.now - start

  puts "Mandelbrot created in #{dt} s"
  ca = 1000.0 + pixels
  GR.clearws
  GR.setviewport(0, 1, 0, 1)
  GR.setcolormap(13)
  GR.cellarray(0, 1, 0, 1, 500, 500, ca)
  GR.updatews

  f *= 0.9
end
