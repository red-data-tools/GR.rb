# frozen_string_literal: true

# https://github.com/sciapp/python-gr/blob/master/examples/drawmolecule.py

require 'gr'
require 'gr3'
require 'numo/narray'

dna = File.readlines(File.expand_path('dna.xyz', __dir__))
dna = dna[2..-2]
dna.map! { |row| row.split(' ') }

positions = dna.map { |row| row[1..3].map(&:to_f) }
atoms = dna.map { |row| row[0] }.map { |a| GR3::ATOM_NUMBERS[a.to_sym] }
colors = atoms.map { |a| GR3::ATOM_COLORS[a] }
radii = atoms.map { |a| GR3::ATOM_RADII[a] }

GR.setviewport(0, 1, 0, 1)

360.times do |i|
  GR.clearws
  GR3.clear
  GR3.drawmolecule(positions, colors, radii, nil, nil, nil, 2, true, i, 45)
  GR3.drawimage(0, 1, 0, 1, 500, 500, GR3::DRAWABLE_GKS)
  GR.settextcolorind(0)
  GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
  GR.text(0.5, 1, 'DNA rendered using GR3.drawmolecule')
  GR.updatews
end
GR3.terminate
