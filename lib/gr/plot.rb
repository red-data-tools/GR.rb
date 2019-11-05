# frozen_string_literal: true

module GR
  class << self
    def set_viewport; end

    def minmax; end

    def set_window; end

    def draw_axes; end

    def draw_polar_axes; end

    def _inqtext; end

    def _text; end

    def draw_legend; end

    def draw_colorbar; end

    def colormap; end

    def to_rgba; end

    # Ruby is object-oriented language.
    # Julia is more functional...
    # def create_context
    # end
    # def restore_context
    # end
    # def figure
    # end

    # def hold
    # end
    # def usecolorscheme
    # end

    # Set current subplot index.
    def subplot; end

    # draw_grid

    # xticks
    # yticks
    # zticks

    # xticklabels
    # yticklabels

    def plot_img; end # should be private?

    def plot_iso; end # should be private?

    def plot_polar; end # should be private?

    # send_meta

    def plot_data; end # should be private?

    def plot_args; end # should be private?

    # Draw one or more line plots.
    def plot_line; end

    def plot_lines; end

    # def plot_line_over oplot_line ?

    # Draw one or more step or staircase plots.
    def plot_step; end

    # Draw one or more scatter plots.
    def plot_scatter; end

    # Draw a stem plot.
    def plot_stem; end

    # Draw a bar plot.
    def plot_bar; end

    def hist; end # should be private?

    # Draw a histogram.
    def plot_histgram; end

    # Draw a polar histogram.
    def plot_polarhistogram; end

    # Draw a contour plot.
    def plot_contour; end

    # Draw a filled contour plot.
    def plot_contourf; end

    # Draw a hexagon binning plot.
    def plot_hexbin; end

    # Draw a heatmap.
    def plot_heatmap; end

    def plot_polarheatmap; end

    # Draw a three-dimensional wireframe plot.
    def plot_wireframe; end

    # Draw a three-dimensional surface plot.
    def plot_surface; end

    def plot_volume; end

    # Draw one or more three-dimensional line plots.
    def plot_line3; end

    # Draw one or more three-dimensional scatter plots.
    def plot_scatter3; end

    # def redraw

    def title; end

    def xlabel; end

    def ylabel; end

    def legend; end

    def xlim; end

    def ylim; end

    def savefig; end

    def meshgrid; end # should be private ?

    def peaks; end # should be private ?

    def imshow; end

    # Draw an isosurface.
    def plot_isosurface; end

    # Draw one or more polar plots.
    def plot_polar; end

    # Draw a triangular surface plot.
    def plot_trisurf; end

    # Draw a triangular contour plot.
    def plot_tricont; end

    def plot_shade; end

    # def set_panzoom ?

    # mainloop

    # GR.plot do
    #
    # end
    #
    # GR.plot(:scatter, * * *)
    def plot; end

    # Object ?

    # a = GR::Bar.new()
    # a.draw ?
    # a = GR::Bar.plot() ?
  end
end
