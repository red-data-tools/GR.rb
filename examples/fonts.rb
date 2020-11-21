# frozen_string_literal: true

require 'gr/plot'

# This time, Plot module is only used for GR::Plot::FONTS.

GR.setwsviewport(0, 0.1, 0.0, 0.2)
GR.setwswindow(0, 0.5, 0, 1)

GR.setcharheight 0.016
GR.text(0.22, 0.95, 'Fonts')

GR.setcharheight 0.012
y = 0.9
GR::Plot::FONTS.each do |name, value|
  GR.settextfontprec(value, value > 200 ? 3 : 0)
  GR.text(0.02, y, value.to_s)
  GR.text(0.1, y, name.to_s)
  y -= 0.025
end
GR.updatews

gets
