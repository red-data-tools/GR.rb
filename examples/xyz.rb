#!/usr/bin/env ruby
# frozen_string_literal: true

# ruby xyz.rb -o dna.mov -r2 -s 100 -t DNA assets/dna.xyz

require 'gr'
require 'gr3'
require 'numo/narray'
require 'optparse'

# command line options

options = { radius: 1.0, size: 500 }
OptionParser.new do |opt|
  opt.banner = \
    <<~MSG
      3D structure visualizer
      usage: ruby xyz.rb [options] <in.xyz>
    MSG
  opt.on('-o', '--output PATH', String) { |v| options[:save_path] = v }
  opt.on('-r', '--radius VALUE', Float) { |v| options[:radius] = v }
  opt.on('-s', '--size VALUE', Integer) { |v| options[:size] = v }
  opt.on('-t', '--title TITLE', String) { |v| options[:title] = v }
  if ARGV.empty?
    warn opt.help; exit 1
  end
  opt.parse!(ARGV)
  options[:title] ||= ARGV[0]
end

# read xyz file format

data = readlines
nrows = data.shift.to_i
puts data.shift
data = data.take(nrows)
data.map! { |row| row.split(/\s+/) }

positions = data.map { |row| row[1..3].map(&:to_f) }
atoms     = data.map { |row| row[0] }.map { |a| GR3::ATOM_NUMBERS[a.upcase] }
colors    = atoms.map { |a| GR3::ATOM_COLORS[a] }
radii     = atoms.map { |a| GR3::ATOM_RADII[a] * options[:radius] }

GR.initgr
GR.setviewport(0, 1, 0, 1)

# save a video
GR.beginprint(options[:save_path]) if options[:save_path]

360.times do |i|
  GR.clearws
  GR3.clear
  GR3.drawmolecule(positions, colors, radii, nil, nil, nil, 2, true, i, 45)
  GR3.drawimage(0, 1, 0, 1, options[:size], options[:size], GR3::DRAWABLE_GKS)
  GR.settextcolorind(0)
  GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
  GR.text(0.5, 1, options[:title])
  GR.updatews
end

GR.endprint if options[:save_path]

GR3.terminate
