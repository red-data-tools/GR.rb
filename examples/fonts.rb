require 'gr/plot'

# This time, Plot module is only used for GR::Plot::FONTS.
GR.initgr

GR.setcharheight 0.015

y = 0.9
GR::Plot::FONTS.each do |name, value|
  p name
  next if value == 234 # workaround
  GR.settextfontprec(value, value > 200 ? 3 : 0)
  GR.text(0.1, y, name)
  y -= 0.025
end
GR.updatews

gets