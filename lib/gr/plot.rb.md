This is a memo to think about the structure of Plot/Figure. 

````ruby

module GR
  # object oriented way
  class PlotBase
  end

  class Line < PlotBase
  end

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
    def plot; end

    # def plot_line_over oplot_line ?

    # Draw one or more step or staircase plots.
    def step; end

    # Draw one or more scatter plots.
    def scatter; end

    # Draw a stem plot.
    def stem; end

    # Draw a bar plot.
    def barplot; end

    def hist; end # should be private?

    # Draw a histogram.
    def histgram; end

    # Draw a polar histogram.
    def polarhistogram; end

    # Draw a contour plot.
    def contour; end
    # GR.contour is already defined in GR::FFI class.

    # Draw a filled contour plot.
    def contourf; end
    # GR.contourf is already defined in GR::FFI class.

    # Draw a hexagon binning plot.
    def hexbin; end
    # GR.hexbin is already defined in GR::FFI class.

    # Draw a heatmap.
    def heatmap; end

    def polarheatmap; end

    # Draw a three-dimensional wireframe plot.
    def wireframe; end

    # Draw a three-dimensional surface plot.
    def surface; end

    def volume; end

    # Draw one or more three-dimensional line plots.
    def plot3; end

    # Draw one or more three-dimensional scatter plots.
    def scatter3; end

    def redraw; end

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
    def isosurface; end

    # Draw one or more polar plots.
    def polar; end

    # Draw a triangular surface plot.
    def trisurf; end

    # Draw a triangular contour plot.
    def tricont; end

    def shade; end

    # def set_panzoom ?

    # mainloop
  end
end

```