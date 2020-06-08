# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/audio_ex.py

require 'wavefile'
require 'gr'

SAMPLES = 2048
SAMPLING_RATE = 44_100 # Hz

assets_dir = File.expand_path('assets', __dir__)
file_path = File.join(assets_dir, 'Monty_Python.wav')

wave = WaveFile::Reader.new(file_path)

GR.setwindow(0, SAMPLES, -30_000, 30_000)
GR.setviewport(0.05, 0.95, 0.05, 0.95)
GR.setlinecolorind(218)
GR.setfillintstyle(1)
GR.setfillcolorind(208)

pid = case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/ # Windows
        spawn("powershell -c (New-Object Media.SoundPlayer #{filepath}).PlaySync();")
      when /darwin|mac os/ # Mac
        spawn("afplay #{file_path}")
      when /linux/ # Linux
        spawn("aplay #{file_path}")
      end
Process.detouch(pid)

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
