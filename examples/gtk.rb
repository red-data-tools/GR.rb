# frozen_string_literal: true

require 'gr'
# To get the ffi pointer, you must load ffi before loading rcairo.
require 'gtk3'
require 'numo/narray'

DFloat = Numo::DFloat

class GRAppWindow < Gtk::ApplicationWindow
  def initialize(application)
    super(application)
    set_title('GTK example')
    set_default_size(500, 500)
    plot_drawable
  end

  def plot_drawable
    drawable = Gtk::DrawingArea.new
    drawable.signal_connect('draw') do |widget, context|
      expose(widget, context)
    end
    add(drawable)
  end

  def expose(_widget, cr)
    ENV['GKS_WSTYPE'] = '142'
    ENV['GKSconid'] = cr.to_ptr.address.to_s
    
    cr.move_to(15, 45)
    cr.set_font_size(30)
    cr.show_text("Contour Plot using Gtk ...")

    xd = -2 + DFloat.new(100).rand * 4
    yd = -2 + DFloat.new(100).rand * 4
    zd = xd * Numo::NMath.exp(-xd * xd - yd * yd)

    h = -0.5 + DFloat.new(20).seq / 19.0

    GR.setviewport(0.1, 0.95, 0.1, 0.85)
    GR.setwindow(-2.0, 2.0, -2.0, 2.0)
    GR.setspace(-0.5, 0.5, 0, 90)
    GR.setmarkersize(1.0)
    GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
    GR.setcharheight(0.024)
    GR.settextalign(2, 0)
    GR.settextfontprec(3, 0)

    x, y, z = GR.gridit(xd, yd, zd, 200, 200)
    GR.surface(x, y, z, 5)
    GR.contour(x, y, h, z, 0)
    GR.polymarker(xd, yd)
    GR.axes(0.25, 0.25, -2, -2, 2, 2, 0.01)

    GR.updatews
  end
end

app = Gtk::Application.new('org.gtk.example', :flags_none)
app.signal_connect 'activate' do |application|
  GRAppWindow.new(application).show_all
end

app.run
