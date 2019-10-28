# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/audio_ex.py

require 'wavefile'
require 'gr'

SAMPLES = 2048
SAMPLING_RATE = 44_100 # Hz

filepath = File.expand_path('Monty_Python.wav', __dir__)
wave = WaveFile::Reader.new(filepath)

GR.setwindow(0, SAMPLES, -30_000, 30_000)
GR.setviewport(0.05, 0.95, 0.05, 0.95)
GR.setlinecolorind(218)
GR.setfillintstyle(1)
GR.setfillcolorind(208)

case RbConfig::CONFIG['host_os']
when /mswin|msys|mingw|cygwin|bccwin|wince|emc/ # Windows
  fork { `powershell -c (New-Object Media.SoundPlayer #{filepath}).PlaySync();` }
when /darwin|mac os/ # Mac
  fork { `afplay #{filepath}` }
when /linux/ # Linux
  fork { `aplay #{filepath}` }
end

count = 1
start_time = Time.now
wave.each_buffer(SAMPLES) do |buffer|
  amplitudes = buffer.samples
  # TODO: power
  GR.clearws
  GR.fillrect(0, SAMPLES, -30_000, 30_000)
  GR.grid(40, 1200, 0, 0, 5, 5)
  next unless amplitudes.size == SAMPLES

  GR.polyline([*1..SAMPLES], amplitudes)
  GR.updatews
  waiting_time = ((SAMPLES / SAMPLING_RATE.to_f) * count - (Time.now - start_time))
  sleep(waiting_time) if waiting_time > 0
  count += 1
end
