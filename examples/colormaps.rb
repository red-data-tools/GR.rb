# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/blob/master/examples/colormaps.jl

require 'gr'

color_maps = %w[uniform temperature grayscale glowing rainbowlike geologic greenscale cyanscale
                bluescale magentascale redscale flame brownscale pilatus autumn bone cool copper
                gray hot hsv jet pink spectral spring summer winter gist_earth gist_heat gist_ncar
                gist_rainbow gist_stern afmhot brg bwr coolwarm CMRmap cubehelix gnuplot gnuplot2
                ocean rainbow seismic terrain viridis inferno plasma magma]

a = [*1000..1255]
xl = 0
GR.setwsviewport(0, 0.25, 0, 0.125)
GR.setwswindow(0, 1, 0, 0.5)
GR.setviewport(0.05, 0.95, 0.025, 0.475)
GR.setcharheight(0.010)
GR.setcharup(-1, 0)
GR.settextcolorind(255)
48.times do |cmap|
  GR.setcolormap(cmap)
  xr = (cmap + 1) / 48.0
  GR.cellarray(xl + 0.002, xr - 0.002, 0.2, 1, 1, 256, a)
  GR.settextalign(1, 3)
  GR.text(0.04 + xr * 0.9, 0.48, cmap.to_s)
  GR.settextalign(3, 3)
  GR.text(0.04 + xr * 0.9, 0.1, color_maps[cmap])
  xl = xr
end
GR.updatews
gets
