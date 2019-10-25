# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/audio_ex.py

require 'wavefile'
require 'gr'

SAMPLES = 2048

filepath = File.expand_path('Monty_Python.wav', __dir__)
wave = WaveFile::Reader.new(filepath)

GR.setwindow(0, SAMPLES, -30_000, 30_000)
GR.setviewport(0.05, 0.95, 0.05, 0.95)
GR.setlinecolorind(218)
GR.setfillintstyle(1)
GR.setfillcolorind(208)

fork { `aplay #{filepath}` }

index = 1
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
  sleep((SAMPLES / 44_100.0) * index - (Time.now - start_time))
  index += 1
end
