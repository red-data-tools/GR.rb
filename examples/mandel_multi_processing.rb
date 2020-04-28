# frozen_string_literal: true

require 'optparse'
require 'numo/narray'
require 'drb/drb'
require 'parallel'

opt = {
  proceses:
    case RbConfig::CONFIG['host_os']
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      puts 'Parallel gem is not supported on windows...'
      exit
    when /darwin|mac os/
      n = `sysctl -n hw.ncpu`.to_i
      n - 1 if n > 4
    when /linux/
      n = `nproc`.to_i
      n - 1 if n > 4
    else
      4
    end,
  epochs: 100,
  port: 12_344
}

OptionParser.new do |op|
  op.on('-p n', '--processes', Integer) { |v| opt[:processes] = v }
  op.on('-e n', '--epochs', Integer) { |v| opt[:epochs] = v }
  op.on('-P n', '--port', Integer) { |v| opt[:port] = v }
  op.parse!(ARGV)
end

druby_server = fork do
  q = Array.new(opt[:epochs])
  DRb.start_service("druby://localhost:#{opt[:port]}", q)
  DRb.thread.join
end

gr_client = fork do
  require 'gr'
  q = DRbObject.new_with_uri("druby://localhost:#{opt[:port]}")
  opt[:epochs].times do |i|
    while (ca = q.at(i)).nil?
      sleep 0.2
    end
    ca += 1000.0
    GR.clearws
    GR.setviewport(0, 1, 0, 1)
    GR.setcolormap(13)
    GR.cellarray(0, 1, 0, 1, 500, 500, ca)
    GR.updatews
    q[i] = nil
    sleep 0.5
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

fs = Array.new(opt[:epochs]) do |i|
  0.5 * (0.9**i)
end

Parallel.each_with_index(fs, in_processes: opt[:processes]) do |f, i|
  image = Numo::UInt8.zeros(500, 500)
  pixels = create_fractal(x - f, x + f, y - f, y + f, image, 400)
  q = DRbObject.new_with_uri("druby://localhost:#{opt[:port]}")
  q[i] = pixels
end

Process.wait(gr_client)
Process.detach(druby_server)
Process.kill(:INT, druby_server)
