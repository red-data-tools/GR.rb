# frozen_string_literal: true

require 'optparse'
require 'numo/narray'
require 'drb/drb'
require 'parallel'

opt = {}
OptionParser.new do |op|
  op.on('-p n', '--processes') { |v| opt[:processes] = v.to_i || 8 }
  op.on('-e n', '--epochs') { |v| opt[:epoch] = v.to_i || 100 }
  op.parse!(ARGV)
end

druby_server = fork do
  q = Array.new(100)
  DRb.start_service('druby://localhost:12345', q)
  DRb.thread.join
end

gr_client = fork do
  require 'gr'
  q = DRbObject.new_with_uri('druby://localhost:12345')
  100.times do |i|
    while (ca = q[i]).nil?
      sleep 0.2
    end
    ca += 1000.0
    GR.clearws
    GR.setviewport(0, 1, 0, 1)
    GR.setcolormap(13)
    GR.cellarray(0, 1, 0, 1, 500, 500, ca)
    GR.updatews
    sleep 1
  end
end

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

fs = opt[:epoch].times.map do |i|
  0.5 * (0.9**i)
end

Parallel.each_with_index(fs, in_processes: opt[:processes]) do |f, i|
  image = Numo::UInt8.zeros(500, 500)
  pixels = create_fractal(x - f, x + f, y - f, y + f, image, 400)
  q = DRbObject.new_with_uri('druby://localhost:12345')
  q[i] = pixels
end

Process.wait(gr_client)
Process.detach(druby_server)
Process.kill(:INT, druby_server)
