# frozen_string_literal: true

require 'gr'
autoload :GR3, 'gr3'

# FIXME: Plot should not depend on Numo::Narrray unless the GR3 module is required.
# Note: The Plot class has a linspace function that is independent of Numo..
require 'numo/narray'

module GR
  # This class offers a simple, matlab-style API built on top of the GR package.
  # The class name Plot may be changed in the future.
  class Plot
    # Why is the Plot class NOT object-oriented?
    #
    # Because the code here is mainly ported from GR.jl.
    # https://github.com/jheinen/GR.jl/blob/master/src/jlgr.jl
    #
    # The Python implementation is also Julia compliant.
    # https://github.com/sciapp/python-gr
    #
    # Julia is not an object-oriented language (at least in 2019).
    # So, you will see many if branches here.
    # This is not the Ruby code style. But it WORKS.
    #
    # I want to thank Josef Heinen(@jheinen), the creator of GR.jl
    # and Florian Rhiem(@FlorianRhiem), the creator of python-gr.
    #
    # If you are interested in an object-oriented implementation,
    # See rubyplot.
    # https://github.com/SciRuby/rubyplot

    # Plot kinds conform to GR.jl
    PLOT_KIND = %i[line step scatter stem hist contour contourf hexbin heatmap
                   nonuniformheatmap wireframe surface plot3 scatter3 imshow
                   isosurface polar polarhist polarheatmap nonuniformpolarheatmap
                   trisurf tricont shade volume].freeze

    # Keyword options conform to GR.jl.
    KW_ARGS = %i[accelerate algorithm alpha ax backgroundcolor barwidth baseline
                 clabels clear clim color colormap crange figsize font grid
                 horizontal isovalue kind label labels levels linewidth location
                 nbins ratio rotation scale size spec subplot tilt title update
                 xaxis xflip xform xlabel xlim xlog xrange xticks yaxis yflip
                 ylabel ylim ylog zflip yrange yticks viewport vp where window
                 zaxis zlabel zlim zlog zrange zticks].freeze

    FONTS = {
      times_roman: 101,
      times_italic: 102,
      times_bold: 103,
      times_bolditalic: 104,
      helvetica_regular: 105,
      helvetica_oblique: 106,
      helvetica_bold: 107,
      helvetica_boldoblique: 108,
      courier_regular: 109,
      courier_oblique: 110,
      courier_bold: 111,
      courier_boldoblique: 112,
      symbol: 113,
      bookman_light: 114,
      bookman_lightitalic: 115,
      bookman_demi: 116,
      bookman_demiitalic: 117,
      newcenturyschlbk_roman: 118,
      newcenturyschlbk_italic: 119,
      newcenturyschlbk_bold: 120,
      newcenturyschlbk_bolditalic: 121,
      avantgarde_book: 122,
      avantgarde_bookoblique: 123,
      avantgarde_demi: 124,
      avantgarde_demioblique: 125,
      palatino_roman: 126,
      palatino_italic: 127,
      palatino_bold: 128,
      palatino_bolditalic: 129,
      zapfchancery_mediumitalic: 130,
      zapfdingbats: 131,
      cmuserif_math: 232, # original: cmuserif-math
      dejavusans: 233
    }.freeze

    @last_plot = nil
    class << self
      attr_accessor :last_plot
    end

    attr_accessor :args, :kvs, :scheme

    def initialize(*raw_args)
      # Keywords are cloned to avoid disruptive changes
      @kvs = raw_args.last.is_a?(Hash) ? raw_args.pop.clone : {}
      @args = plot_args(raw_args) # method name is the same as Julia/Python

      # Check keyword options.
      kvs.each_key { |k| warn "Unknown keyword: #{k}" unless KW_ARGS.include? k }

      # label(singular form) is a original keyword arg which GR.jl does not have.
      kvs[:labels] ||= [kvs[:label]] if kvs.has_key? :label

      # Don't use ||= here, because we need to tell `false` from `nil`
      kvs[:size]    = [600, 450]   unless kvs.has_key? :size
      kvs[:ax]      = false        unless kvs.has_key? :ax
      kvs[:subplot] = [0, 1, 0, 1] unless kvs.has_key? :subplot
      kvs[:clear]   = true         unless kvs.has_key? :clear
      kvs[:update]  = true         unless kvs.has_key? :update

      @scheme     = 0
      @background = 0xffffff
      # @handle     = nil           # This variable will be used in gr_meta

      self.class.last_plot = self
    end

    def set_viewport(kind, subplot)
      mwidth, mheight, width, height = GR.inqdspsize
      dpi = width / mwidth * 0.0254
      w, h = if kvs[:figsize]
               [(0.0254 * width  * kvs[:figsize][0] / mwidth),
                (0.0254 * height * kvs[:figsize][1] / mheight)]
             elsif dpi > 200
               kvs[:size].map { |i| i * dpi / 100 }
             else
               kvs[:size]
             end

      vp = subplot.clone

      if w > h
        ratio = h / w.to_f
        msize = mwidth * w / width
        GR.setwsviewport(0, msize, 0, msize * ratio)
        GR.setwswindow(0, 1, 0, ratio)
        vp[2] *= ratio
        vp[3] *= ratio
      else
        ratio = w / h.to_f
        msize = mheight * h / height
        GR.setwsviewport(0, msize * ratio, 0, msize)
        GR.setwswindow(0, ratio, 0, 1)
        vp[0] *= ratio
        vp[1] *= ratio
      end

      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        extent = [vp[1] - vp[0], vp[3] - vp[2]].min
        vp1 = 0.5 * (vp[0] + vp[1] - extent)
        vp2 = 0.5 * (vp[0] + vp[1] + extent)
        vp3 = 0.5 * (vp[2] + vp[3] - extent)
        vp4 = 0.5 * (vp[2] + vp[3] + extent)
      else
        vp1, vp2, vp3, vp4 = vp
      end

      left_margin = kvs.has_key?(:ylabel) ? 0.05 : 0
      right_margin = if %i[contour contourf hexbin heatmap nonuniformheatmap polarheatmap
                           nonuniformpolarheatmap surface trisurf volume].include?(kind)
                       (vp2 - vp1) * 0.1
                     else
                       0
                     end
      bottom_margin = kvs.has_key?(:xlabel) ? 0.05 : 0
      top_margin = kvs.has_key?(:title) ? 0.075 : 0

      viewport = [vp1 + (0.075 + left_margin) * (vp2 - vp1),
                  vp1 + (0.95 - right_margin) * (vp2 - vp1),
                  vp3 + (0.075 + bottom_margin) * (vp4 - vp3),
                  vp3 + (0.975 - top_margin) * (vp4 - vp3)]

      if %i[line step scatter stem].include?(kind) && kvs[:labels]
        location = kvs[:location] || 1
        if [11, 12, 13].include?(location)
          w, h = legend_size
          viewport[1] -= w + 0.1
        end
      end

      GR.setviewport(*viewport)

      kvs[:viewport] = viewport
      kvs[:vp]       = vp
      kvs[:ratio]    = ratio

      if kvs[:backgroundcolor]
        GR.savestate
        GR.selntran(0)
        GR.setfillintstyle(GR::INTSTYLE_SOLID)
        GR.setfillcolorind(kvs[:backgroundcolor])
        if w > h
          GR.fillrect(subplot[0], subplot[1],
                      ratio * subplot[2], ratio * subplot[3])
        else
          GR.fillrect(ratio * subplot[0], ratio * subplot[1],
                      subplot[2], subplot[3])
        end
        GR.selntran(1)
        GR.restorestate
      end

      if %i[polar polarhist polarheatmap nonuniformpolarheatmap].include? kind
        xmin, xmax, ymin, ymax = viewport
        xcenter = 0.5 * (xmin + xmax)
        ycenter = 0.5 * (ymin + ymax)
        r = 0.5 * [xmax - xmin, ymax - ymin].min
        GR.setviewport(xcenter - r, xcenter + r, ycenter - r, ycenter + r)
      end
    end

    def set_window(kind)
      scale = 0
      unless %i[polar polarhist polarheatmap nonuniformpolarheatmap].include?(kind)
        scale |= GR::OPTION_X_LOG  if kvs[:xlog]
        scale |= GR::OPTION_Y_LOG  if kvs[:ylog]
        scale |= GR::OPTION_Z_LOG  if kvs[:zlog]
        scale |= GR::OPTION_FLIP_X if kvs[:xflip]
        scale |= GR::OPTION_FLIP_Y if kvs[:yflip]
        scale |= GR::OPTION_FLIP_Z if kvs[:zflip]
      end
      kvs[:scale] = scale

      if kvs.has_key?(:panzoom)
        xmin, xmax, ymin, ymax = GR.panzoom(*kvs[:panzoom])
        kvs[:xrange] = [xmin, xmax]
        kvs[:yrange] = [ymin, ymax]
      else
        minmax(kind)
      end

      major_count = if %i[wireframe surface plot3 scatter3 polar polarhist
                          polarheatmap nonuniformpolarheatmap trisurf volume].include?(kind)
                      2
                    else
                      5
                    end

      kvs[:xticks] = [kvs[:xticks], major_count] if kvs[:xticks].is_a? Numeric
      kvs[:yticks] = [kvs[:yticks], major_count] if kvs[:yticks].is_a? Numeric
      kvs[:zticks] = [kvs[:zticks], major_count] if kvs[:zticks].is_a? Numeric

      xmin, xmax = kvs[:xrange]
      if %i[heatmap polarheatmap].include?(kind) && kvs.has_key?(:xlim)
        xmin -= 0.5
        xmax += 0.5
      end
      xtick, majorx = if (scale & GR::OPTION_X_LOG) == 0
                        if !%i[heatmap polarheatmap].include?(kind) &&
                           !kvs.has_key?(:xlim) &&
                           !kvs[:panzoom]
                          xmin, xmax = GR.adjustlimits(xmin, xmax)
                        end
                        if kvs.has_key?(:xticks)
                          kvs[:xticks]
                        else
                          [auto_tick(xmin, xmax) / major_count, major_count]
                        end
                      else
                        [1, 1]
                      end
      xorg = (scale & GR::OPTION_FLIP_X) == 0 ? [xmin, xmax] : [xmax, xmin]
      kvs[:xaxis] = xtick, xorg, majorx

      ymin, ymax = kvs[:yrange]
      if %i[heatmap polarheatmap].include?(kind) && kvs.has_key?(:ylim)
        ymin -= 0.5
        ymax += 0.5
      end
      if kind == :hist
        if kvs[:horizontal] && !kvs.has_key?(:xlim)
          xmin = (scale & GR::OPTION_X_LOG) == 0 ? 0 : 1
        elsif !kvs.has_key?(:ylim)
          ymin = (scale & GR::OPTION_Y_LOG) == 0 ? 0 : 1
        end
      end
      ytick, majory = if (scale & GR::OPTION_Y_LOG) == 0
                        if !%i[heatmap polarheatmap].include?(kind) &&
                           !kvs.has_key?(:ylim) &&
                           !kvs[:panzoom]
                          ymin, ymax = GR.adjustlimits(ymin, ymax)
                        end
                        if kvs.has_key?(:yticks)
                          kvs[:yticks]
                        else
                          [auto_tick(ymin, ymax) / major_count, major_count]
                        end
                      else
                        [1, 1]
                      end
      yorg = (scale & GR::OPTION_FLIP_Y) == 0 ? [ymin, ymax] : [ymax, ymin]
      kvs[:yaxis] = ytick, yorg, majory

      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        zmin, zmax = kvs[:zrange]
        ztick, majorz = if (scale & GR::OPTION_Z_LOG) == 0
                          zmin, zmax = GR.adjustlimits(zmin, zmax) if kvs.has_key?(:zlim)
                          if kvs.has_key?(:zticks)
                            kvs[:zticks]
                          else
                            [auto_tick(zmin, zmax) / major_count, major_count]
                          end
                        else
                          [1, 1]
                        end
        zorg = (scale & GR::OPTION_FLIP_Z) == 0 ? [zmin, zmax] : [zmax, zmin]
        kvs[:zaxis] = ztick, zorg, majorz
      end

      kvs[:window] = xmin, xmax, ymin, ymax
      if %i[polar polarhist polarheatmap nonuniformpolarheatmap trisurf].include?(kind)
        GR.setwindow(-1, 1, -1, 1)
      else
        GR.setwindow(xmin, xmax, ymin, ymax)
      end
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        rotation = kvs[:rotation] || 40
        tilt     = kvs[:tilt]     || 60
        GR.setwindow3d(xmin, xmax, ymin, ymax, zmin, zmax)
        GR.setspace3d(-rotation, tilt, 30, 0)
      end

      kvs[:scale] = scale
      GR.setscale(scale)
    end

    def draw_axes(kind, pass = 1)
      viewport = kvs[:viewport]
      vp = kvs[:vp]
      _ratio = kvs[:ratio]
      xtick, xorg, majorx = kvs[:xaxis]
      ytick, yorg, majory = kvs[:yaxis]
      drawgrid = kvs.has_key?(:grid) ? kvs[:grid] : true
      xtick = 10 if kvs[:scale] & GR::OPTION_X_LOG != 0
      ytick = 10 if kvs[:scale] & GR::OPTION_Y_LOG != 0
      GR.setlinecolorind(1)
      diag = Math.sqrt((viewport[1] - viewport[0])**2 + (viewport[3] - viewport[2])**2)
      GR.setlinewidth(1)
      ticksize = 0.0075 * diag
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        charheight = [0.024 * diag, 0.012].max
        GR.setcharheight(charheight)
        ztick, zorg, majorz = kvs[:zaxis]
        if pass == 1 && drawgrid
          GR.grid3d(xtick, 0, ztick, xorg[0], yorg[1], zorg[0], 2, 0, 2)
          GR.grid3d(0, ytick, 0, xorg[0], yorg[1], zorg[0], 0, 2, 0)
        else
          GR.axes3d(xtick, 0, ztick, xorg[0], yorg[0], zorg[0], majorx, 0, majorz, -ticksize)
          GR.axes3d(0, ytick, 0, xorg[1], yorg[0], zorg[0], 0, majory, 0, ticksize)
        end
      else
        charheight = [0.018 * diag, 0.012].max
        GR.setcharheight(charheight)
        if %i[heatmap nonuniformheatmap shade].include?(kind)
          ticksize = -ticksize
        elsif drawgrid
          GR.grid(xtick, ytick, 0, 0, majorx, majory)
        end
        if kvs.has_key?(:xticklabels) || kvs.has_key?(:yticklabels)
          fx = if kvs.has_key?(:xticklabels)
                 GRCommons::Fiddley::Function.new(
                   :void, %i[double double string double]
                 ) do |x, y, _svalue, value|
                   label = value < 0 ? '' : kvs[:xticklabels][value] || ''
                   GR.textext(x, y, label)
                 end
               else
                 GRCommons::Fiddley::Function.new(
                   :void, %i[double double string double]
                 ) do |x, y, _svalue, value|
                   GR.textext(x, y, value.to_s)
                 end
               end
          fy = if kvs.has_key?(:yticklabels)
                 GRCommons::Fiddley::Function.new(
                   :void, %i[double double string double]
                 ) do |x, y, _svalue, value|
                   label = value < 0 ? '' : kvs[:yticklabels][value] || ''
                   GR.textext(x, y, label)
                 end
               else
                 GRCommons::Fiddley::Function.new(
                   :void, %i[double double string double]
                 ) do |x, y, _svalue, value|
                   GR.textext(x, y, value.to_s)
                 end
               end
          GR.axeslbl(xtick, ytick, xorg[0], yorg[0], majorx, majory, ticksize, fx, fy)
        else
          GR.axes(xtick, ytick, xorg[0], yorg[0], majorx, majory, ticksize)
        end
        GR.axes(xtick, ytick, xorg[1], yorg[1], -majorx, -majory, -ticksize)
      end

      if kvs.has_key?(:title)
        GR.savestate
        GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
        text(0.5 * (viewport[0] + viewport[1]), vp[3], kvs[:title].to_s)
        GR.restorestate
      end
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        xlabel = (kvs[:xlabel] || '').to_s
        ylabel = (kvs[:ylabel] || '').to_s
        zlabel = (kvs[:zlabel] || '').to_s
        GR.titles3d(xlabel, ylabel, zlabel)
      else
        if kvs.has_key?(:xlabel)
          GR.savestate
          GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_BOTTOM)
          text(0.5 * (viewport[0] + viewport[1]), vp[2] + 0.5 * charheight, kvs[:xlabel].to_s)
          GR.restorestate
        end
        if kvs.has_key?(:ylabel)
          GR.savestate
          GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
          GR.setcharup(-1, 0)
          text(vp[0] + 0.5 * charheight, 0.5 * (viewport[2] + viewport[3]), kvs[:ylabel].to_s)
          GR.restorestate
        end
      end
    end

    def draw_polar_axes
      viewport = kvs[:viewport]
      diag = Math.sqrt((viewport[1] - viewport[0])**2 + (viewport[3] - viewport[2])**2)
      charheight = [0.018 * diag, 0.012].max

      window = kvs[:window]
      rmin = window[2]
      rmax = window[3]

      GR.savestate
      GR.setcharheight(charheight)
      GR.setlinetype(GR::LINETYPE_SOLID)

      tick = auto_tick(rmin, rmax)
      n = ((rmax - rmin) / tick + 0.5).round
      (n + 1).times do |i|
        r = i.to_f / n
        if i.even?
          GR.setlinecolorind(88)
          GR.drawarc(-r, r, -r, r, 0, 359) if i > 0
          GR.settextalign(GR::TEXT_HALIGN_LEFT, GR::TEXT_VALIGN_HALF)
          x, y = GR.wctondc(0.05, r)
          GR.text(x, y, (rmin + i * tick).to_s) # FIXME: round. significant digits.
        else
          GR.setlinecolorind(90)
          GR.drawarc(-r, r, -r, r, 0, 359)
        end
      end
      0.step(by: 45, to: 315) do |alpha|
        sinf = Math.sin(alpha * Math::PI / 180)
        cosf = Math.cos(alpha * Math::PI / 180)
        GR.polyline([cosf, 0], [sinf, 0])
        GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_HALF)
        x, y = GR.wctondc(1.1 * cosf, 1.1 * sinf)
        GR.textext(x, y, "#{alpha}^o")
      end
      GR.restorestate
    end

    def plot_polar(θ, ρ)
      window = kvs[:window]
      rmax = window[3].to_f
      ρ = ρ.map { |i| i / rmax }
      n = ρ.length
      x = []
      y = []
      n.times do |i|
        x << ρ[i] * Math.cos(θ[i])
        y << ρ[i] * Math.sin(θ[i])
      end
      GR.polyline(x, y)
    end

    def plot_img(img)
      viewport = kvs[:vp].clone
      viewport[3] -= 0.05 if kvs.has_key?(:title)
      vp = kvs[:vp]

      if img.is_a? String
        width, height, data = GR.readimage(img)
      else
        height, width = img.shape
        cmin, cmax = kvs[:crange]
        data = img.map { |i| normalize_color(i, cmin, cmax) }
        data = data.map { |i| (1000 + i * 255).round }
      end

      if width * (viewport[3] - viewport[2]) < height * (viewport[1] - viewport[0])
        w = width.to_f / height * (viewport[3] - viewport[2])
        xmin = [0.5 * (viewport[0] + viewport[1] - w), viewport[0]].max
        xmax = [0.5 * (viewport[0] + viewport[1] + w), viewport[1]].min
        ymin = viewport[2]
        ymax = viewport[3]
      else
        h = height.to_f / width * (viewport[1] - viewport[0])
        xmin = viewport[0]
        xmax = viewport[1]
        ymin = [0.5 * (viewport[3] + viewport[2] - h), viewport[2]].max
        ymax = [0.5 * (viewport[3] + viewport[2] + h), viewport[3]].min
      end

      GR.selntran(0)
      GR.setscale(0)
      if kvs.has_key?(:xflip)
        tmp = xmax
        xmax = xmin
        xmin = tmp
      end
      if kvs.has_key?(:yflip)
        tmp = ymax
        ymax = ymin
        ymin = tmp
      end
      if img.is_a? String
        GR.drawimage(xmin, xmax, ymin, ymax, width, height, data)
      else
        GR.cellarray(xmin, xmax, ymin, ymax, width, height, data)
      end

      if kvs.has_key?(:title)
        GR.savestate
        GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
        text(0.5 * (viewport[0] + viewport[1]), vp[3], kvs[:title].to_s)
        GR.restorestate
      end
      GR.selntran(1)
    end

    def plot_iso(v)
      viewport = kvs[:viewport]

      if viewport[3] - viewport[2] < viewport[1] - viewport[0]
        width = viewport[3] - viewport[2]
        centerx = 0.5 * (viewport[0] + viewport[1])
        xmin = [centerx - 0.5 * width, viewport[0]].max
        xmax = [centerx + 0.5 * width, viewport[1]].min
        ymin = viewport[2]
        ymax = viewport[3]
      else
        height = viewport[1] - viewport[0]
        centery = 0.5 * (viewport[2] + viewport[3])
        xmin = viewport[0]
        xmax = viewport[1]
        ymin = [centery - 0.5 * height, viewport[2]].max
        ymax = [centery + 0.5 * height, viewport[3]].min
      end

      GR.selntran(0)
      v = Numo::DFloat.cast(v) if v.is_a? Array
      values = ((v - v.min) / (v.max - v.min) * (2**16 - 1)).round
      values = Numo::UInt16.cast(values)
      nx, ny, nz = v.shape
      isovalue = ((kvs[:isovalue] || 0.5) - v.min) / (v.max - v.min)
      rotation = ((kvs[:rotation] || 40) * Math::PI / 180.0)
      tilt = ((kvs[:tilt] || 70) * Math::PI / 180.0)
      r = 2.5
      GR3.clear
      mesh = GR3.createisosurfacemesh(values, [2.0 / (nx - 1), 2.0 / (ny - 1), 2.0 / (nz - 1)],
                                      [-1, -1, -1],
                                      (isovalue * (2**16 - 1)).round)
      color = kvs[:color] || [0.0, 0.5, 0.8]
      GR3.setbackgroundcolor(1, 1, 1, 0)
      GR3.drawmesh(mesh, 1, [0, 0, 0], [0, 0, 1], [0, 1, 0], color, [1, 1, 1])
      GR3.cameralookat(r * Math.sin(tilt) * Math.sin(rotation),
                       r * Math.cos(tilt), r * Math.sin(tilt) * Math.cos(rotation),
                       0, 0, 0, 0, 1, 0)
      GR3.drawimage(xmin, xmax, ymin, ymax, 500, 500, GR3::DRAWABLE_GKS)
      GR3.deletemesh(mesh)
      GR.selntran(1)
    end

    def colorbar(off = 0, colors = 256)
      GR.savestate
      viewport = kvs[:viewport]
      zmin, zmax = kvs[:zrange]
      mask = (GR::OPTION_Z_LOG | GR::OPTION_FLIP_Y | GR::OPTION_FLIP_Z)
      options = if kvs.has_key?(:zflip)
                  (GR.inqscale | GR::OPTION_FLIP_Y)
                elsif kvs.has_key?(:yflip)
                  GR.inqscale & ~GR::OPTION_FLIP_Y
                else
                  GR.inqscale
                end
      GR.setscale(options & mask)
      h = 0.5 * (zmax - zmin) / (colors - 1)
      GR.setwindow(0, 1, zmin, zmax)
      GR.setviewport(viewport[1] + 0.02 + off, viewport[1] + 0.05 + off,
                     viewport[2], viewport[3])
      l = linspace(1000, 1255, colors).map(&:round)
      GR.cellarray(0, 1, zmax + h, zmin - h, 1, colors, l)
      GR.setlinecolorind(1)
      diag = Math.sqrt((viewport[1] - viewport[0])**2 + (viewport[3] - viewport[2])**2)
      charheight = [0.016 * diag, 0.012].max
      GR.setcharheight(charheight)
      if kvs[:scale] & GR::OPTION_Z_LOG == 0
        ztick = auto_tick(zmin, zmax)
        GR.axes(0, ztick, 1, zmin, 0, 1, 0.005)
      else
        GR.setscale(GR::OPTION_Y_LOG)
        GR.axes(0, 2, 1, zmin, 0, 1, 0.005)
      end
      GR.restorestate
    end

    def plot_data(_figure = true)
      # GR.init

      # target = GR.displayname
      # if flag && target != None
      #   if target == "js" || target == "meta"
      #       send_meta(0)
      #   else
      #       send_serialized(target)
      #   end
      #   return
      # end

      kind = kvs[:kind] || :line
      GR.clearws if kvs[:clear]

      if scheme != 0
        # Not yet.
      end

      if kvs.has_key?(:font)
        name = kvs[:font]
        # 'Cmuserif-Math' => :cmuserif_math
        sym_name = name.to_s.gsub('-', '_').downcase.to_sym
        if FONTS.include?(sym_name)
          font = FONTS[sym_name]
          GR.settextfontprec(font, font > 200 ? 3 : 0)
        else
          font = GR.loadfont(name)
          if font >= 0
            GR.settextfontprec(font, 3)
          else
            warn "Unknown font name: #{name}"
          end
        end
      else
        # The following fonts are the default in GR.jl
        # Japanese, Chinese, Korean, etc. cannot be displayed.

        # GR.settextfontprec(232, 3) # CM Serif Roman
      end

      set_viewport(kind, kvs[:subplot])
      unless kvs[:ax]
        set_window(kind)
        if %i[polar polarhist].include?(kind)
          draw_polar_axes
        elsif !%i[imshow isosurface polarheatmap nonuniformpolarheatmap].include?(kind)
          draw_axes(kind)
        end
      end

      if kvs.has_key?(:colormap)
        GR.setcolormap(kvs[:colormap])
      else
        GR.setcolormap(GR::COLORMAP_VIRIDIS)
      end

      GR.uselinespec(' ')
      args.each do |x, y, z, c, spec|
        spec ||= kvs[:spec] ||= ''
        GR.savestate
        GR.settransparency(kvs[:alpha]) if kvs.has_key?(:alpha)

        case kind

        when :line
          mask = GR.uselinespec(spec)
          linewidth = kvs[:linewidth]
          # Slightly different from Julia,
          # Because the implementation of polyline and polymarker is different.
          z ||= linewidth # FIXME
          GR.polyline(x, y, z, c) if hasline(mask)
          GR.polymarker(x, y, z, c) if hasmarker(mask)

        when :step
          mask = GR.uselinespec(spec)
          if hasline(mask)
            where = kvs[:where] || 'mid'
            n = x.length
            xs = [x[0]]
            case where
            when 'pre'
              ys = [y[0]]
              (n - 1).times do |i|
                xs << x[i]     << x[i + 1]
                ys << y[i + 1] << y[i + 1]
              end
            when 'post'
              ys = [y[0]]
              (n - 1).times do |i|
                xs << x[i + 1] << x[i + 1]
                ys << y[i]     << y[i + 1]
              end
            else
              ys = []
              (n - 1).times do |i|
                xs << 0.5 * (x[i] + x[i + 1]) << 0.5 * (x[i] + x[i + 1])
                ys << y[i] << y[i]
              end
              xs << x[n - 1]
              ys << y[n - 1] << y[n - 1]
            end
            GR.polyline(xs, ys)
          end
          GR.polymarker(x, y) if hasmarker(mask)

        when :scatter
          GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
          z = z&.map { |i| i * 0.01 }
          c = c&.map { |i| normalize_color(i, *kvs[:crange]) }
          GR.polymarker(x, y, z, c)

        when :stem
          GR.setlinecolorind(1)
          GR.polyline(kvs[:window][0..1], [0, 0])
          GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
          GR.uselinespec(spec)
          x = x.to_a if narray?(x)
          y = y.to_a if narray?(y)
          x.zip(y).each do |xi, yi|
            GR.polyline([xi, xi], [0, yi])
          end
          GR.polymarker(x, y)

        when :hist
          if kvs[:horizontal]
            xmin = kvs[:window][0]
            x.length.times do |i|
              GR.setfillcolorind(989)
              GR.setfillintstyle(GR::INTSTYLE_SOLID)
              GR.fillrect(xmin, x[i], y[i], y[i + 1])
              GR.setfillcolorind(1)
              GR.setfillintstyle(GR::INTSTYLE_HOLLOW)
              GR.fillrect(xmin, x[i], y[i], y[i + 1])
            end
          else
            ymin = kvs[:window][2]
            y.length.times do |i|
              GR.setfillcolorind(989)
              GR.setfillintstyle(GR::INTSTYLE_SOLID)
              GR.fillrect(x[i], x[i + 1], ymin, y[i])
              GR.setfillcolorind(1)
              GR.setfillintstyle(GR::INTSTYLE_HOLLOW)
              GR.fillrect(x[i], x[i + 1], ymin, y[i])
            end
          end

        when :polarhist
          ymax = kvs[:window][3].to_f
          ρ = y.map { |i| i / ymax }
          θ = x.map { |i| i * 180 / Math::PI }
          (1...ρ.length).each do |i|
            GR.setfillcolorind(989)
            GR.setfillintstyle(GR::INTSTYLE_SOLID)
            GR.fillarc(-ρ[i], ρ[i], -ρ[i], ρ[i], θ[i - 1], θ[i])
            GR.setfillcolorind(1)
            GR.setfillintstyle(GR::INTSTYLE_HOLLOW)
            GR.fillarc(-ρ[i], ρ[i], -ρ[i], ρ[i], θ[i - 1], θ[i])
          end

        when :polarheatmap, :nonuniformpolarheatmap
          w, h = z.shape
          cmap = colormap
          cmin, cmax = kvs[:zrange]
          data = z.map { |i| normalize_color(i, cmin, cmax) }
          data.reverse(axis: 0) if kvs[:xflip]
          data.reverse(axis: 1) if kvs[:yflip]
          colors = data * 255 + 1000
          colors = colors.transpose # Julia is column major
          case kind
          when :polarheatmap
            GR.polarcellarray(0, 0, 0, 360, 0, 1, w, h, colors)
          when :nonuniformpolarheatmap
            ymax = y.max.to_f
            ρ = y.map { |i| i / ymax }
            θ = x.map { |i| i * 180 / Math::PI }
            GR.nonuniformpolarcellarray(θ, ρ, w, h, colors)
          end
          draw_polar_axes
          kvs[:zrange] = [cmin, cmax]
          colorbar

        when :contour, :contourf
          zmin, zmax = kvs[:zrange]
          if narray?(z) && z.ndim == 2
            a, b = z.shape
            x = (1..b).to_a
            y = (1..a).to_a
            zmin, zmax = z.minmax
          elsif equal_length(x, y, z)
            x, y, z = GR.gridit(x, y, z, 200, 200)
            zmin, zmax = z.compact.minmax # compact : removed nil
          end

          # kvs[:zlim] is supposed to be Array or Range
          if kvs.has_key?(:zlim)
            zmin = kvs[:zlim].first if kvs[:zlim].first
            zmax = kvs[:zlim].last if kvs[:zlim].last
          end
          GR.setprojectiontype(0)
          GR.setspace(zmin, zmax, 0, 90)
          levels = kvs[:levels] || 0
          clabels = kvs[:clabels] || false
          if levels.is_a? Integer
            hmin, hmax = GR.adjustrange(zmin, zmax)
            h = linspace(hmin, hmax, levels == 0 ? 21 : levels + 1)
          else
            h = levels
          end
          case kind
          when :contour
            GR._contour_(x, y, h, z, clabels ? 1 : 1000)
          when :contourf
            GR._contourf_(x, y, h, z, clabels ? 1 : 0)
          end
          colorbar(0, h.length)

        when :hexbin
          nbins = kvs[:nbins] || 40
          cntmax = GR._hexbin_(x, y, nbins)
          if cntmax > 0
            kvs[:zrange] = [0, cntmax]
            colorbar
          end

        when :heatmap, :nonuniformheatmap
          case z
          when Array
            if z.all? { |zi| zi.size = z[0].size }
              w = z.size
              h = z[0].size
            else
              raise
            end
          when ->(obj) { narray?(obj) }
            w, h = z.shape
          else
            raise
          end
          cmap = colormap
          cmin, cmax = kvs[:crange]
          levels = kvs[:levels] || 256
          data = z.flatten.to_a.map { |i| normalize_color(i, cmin, cmax) } # NArray -> Array
          if kind == :heatmap
            rgba = data.map { |v| to_rgba(v, cmap) }
            GR.drawimage(0.5, w + 0.5, h + 0.5, 0.5, w, h, rgba)
          else
            colors = data.map { |i| (1000 + i * 255).round }
            GR.nonuniformcellarray(x, y, w, h, colors)
          end
          colorbar(0, levels)

        when :wireframe
          if narray?(z) && z.ndim == 2
            a, b = z.shape
            x = (1..b).to_a
            y = (1..a).to_a
          elsif equal_length(x, y, z)
            x, y, z = GR.gridit(x, y, z, 50, 50)
          end
          GR.setfillcolorind(0)
          GR._surface_(x, y, z, GR::OPTION_FILLED_MESH)
          draw_axes(kind, 2)

        when :surface
          if narray?(z) && z.ndim == 2
            a, b = z.shape
            x = (1..b).to_a
            y = (1..a).to_a
          elsif equal_length(x, y, z)
            x, y, z = GR.gridit(x, y, z, 200, 200)
          end
          if kvs[:accelerate] == false
            GR._surface_(x, y, z, GR::OPTION_COLORED_MESH)
          else
            require 'gr3'
            GR3.clear
            GR3.surface(x, y, z, GR::OPTION_COLORED_MESH)
          end
          draw_axes(kind, 2)
          colorbar(0.05)

        when :volume
          algorithm = kvs[:algorithm] || 0
          require 'gr3'
          GR3.clear
          dmin, dmax = GR3.volume(z, algorithm)
          draw_axes(kind, 2)
          kvs[:zrange] = [dmin, dmax]
          colorbar(0.05)

        when :plot3
          mask = GR.uselinespec(spec)
          GR.polyline3d(x, y, z) if hasline(mask)
          GR.polymarker3d(x, y, z) if hasmarker(mask)
          draw_axes(kind, 2)

        when :scatter3
          GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
          if c
            cmin, cmax = kvs[:crange]
            c = c.map { |i| normalize_color(i, cmin, cmax) }
            cind = c.map { |i| (1000 + i * 255).round }
            x.length.times do |i|
              GR.setmarkercolorind(cind[i])
              GR.polymarker3d([x[i]], [y[i]], [z[i]])
            end
          else
            GR.polymarker3d(x, y, z)
          end
          draw_axes(kind, 2)

        when :imshow
          plot_img(z)

        when :isosurface
          plot_iso(z)

        when :polar
          GR.uselinespec(spec)
          plot_polar(x, y)

        when :trisurf
          GR.trisurface(x, y, z)
          draw_axes(kind, 2)
          colorbar(0.05)

        when :tricont
          zmin, zmax = kvs[:zrange]
          levels = linspace(zmin, zmax, 20)
          GR.tricontour(x, y, z, levels)

        when :shade
          xform = kvs[:xform] || 5
          if x.to_a.include? Float::NAN # FIXME: Ruby is different from Julia?
            # How to check NArray?
            GR.shadelines(x, y, xform: xform)
          else
            GR.shadepoints(x, y, xform: xform)
          end

        when :bar
          0.step(x.length - 1, 2) do |i|
            GR.setfillcolorind(989)
            GR.setfillintstyle(GR::INTSTYLE_SOLID)
            GR.fillrect(x[i], x[i + 1], y[i], y[i + 1])
            GR.setfillcolorind(1)
            GR.setfillintstyle(GR::INTSTYLE_HOLLOW)
            GR.fillrect(x[i], x[i + 1], y[i], y[i + 1])
          end
        end

        GR.restorestate
      end

      draw_legend if %i[line step scatter stem].include?(kind) && kvs.has_key?(:labels)

      if kvs[:update]
        GR.updatews
        # if GR.isinline()
        #  restore_context()
        #  return GR.show()
        # end
      end

      # flag && restore_context()
    end

    def draw_legend
      w, h = legend_size
      viewport = kvs[:viewport]
      location = kvs[:location] || 1
      num_labels = kvs[:labels].length
      GR.savestate
      GR.selntran 0
      GR.setscale 0
      px = case location
           when 11, 12, 13
             viewport[1] + 0.11
           when 8, 9, 10
             0.5 * (viewport[0] + viewport[1] - w + 0.05)
           when 2, 3, 6
             viewport[0] + 0.11
           else
             viewport[1] - 0.05 - w
           end
      py = case location
           when 5, 6, 7, 10, 12
             0.5 * (viewport[2] + viewport[3] + h - 0.03)
           when 13
             viewport[2] + h
           when 3, 4, 8
             viewport[2] + h + 0.03
           when 11
             viewport[3] - 0.03
           else
             viewport[3] - 0.06
           end
      GR.setfillintstyle(GR::INTSTYLE_SOLID)
      GR.setfillcolorind(0)
      GR.fillrect(px - 0.08, px + w + 0.02, py + 0.03, py - h)
      GR.setlinetype(GR::LINETYPE_SOLID)
      GR.setlinecolorind(1)
      GR.setlinewidth(1)
      GR.drawrect(px - 0.08, px + w + 0.02, py + 0.03, py - h)
      i = 0
      GR.uselinespec(' ')
      args.each do |_x, _y, _z, _c, spec|
        if i < num_labels
          label = kvs[:labels][i]
          label = label.to_s
          _tbx, tby = inqtext(0, 0, label)
          dy = [(tby[2] - tby[0]) - 0.03, 0].max
          py -= 0.5 * dy
        end
        GR.savestate
        mask = GR.uselinespec(spec || '')
        GR.polyline([px - 0.07, px - 0.01], [py, py]) if hasline(mask)
        GR.polymarker([px - 0.06, px - 0.02], [py, py]) if hasmarker(mask)
        GR.restorestate
        GR.settextalign(GR::TEXT_HALIGN_LEFT, GR::TEXT_VALIGN_HALF)
        if i < num_labels
          text(px, py, label)
          py -= 0.5 * dy
          i += 1
        end
        py -= 0.03
      end
      GR.selntran(1)
      GR.restorestate
    end

    def to_svg
      ## Need IRuby improvemend.
      GR.show(false) if ENV['GKS_WSTYPE'] == 'svg'
    end

    private

    def hasline(mask)
      mask == 0x00 || (mask & 0x01 != 0)
    end

    def hasmarker(mask)
      mask & 0x02 != 0
    end

    def colormap
      # rgb
      Array.new(256) do |colorind|
        color = GR.inqcolor(1000 + colorind)
        [(color & 0xff)         / 255.0,
         ((color >> 8)  & 0xff) / 255.0,
         ((color >> 16) & 0xff) / 255.0]
      end
    end

    def to_rgba(value, cmap)
      begin
        r, g, b = cmap[(value * 255).round]
        a = 1.0
      rescue StandardError # nil
        r = 0
        g = 0
        b = 0
        a = 0
      end

      ((a * 255).round << 24) + ((b * 255).round << 16) +
        ((g * 255).round << 8) + (r * 255).round
    end

    # https://gist.github.com/rysk-t/8d1aef0fb67abde1d259#gistcomment-1925021
    def linspace(low, high, num)
      [*0..(num - 1)].collect { |i| low + i.to_f * (high - low) / (num - 1) }
    end

    def plot_args(args)
      # FIXME
      args = [args] unless args.all? do |i|
                             i.is_a?(Array) && (i[0].is_a?(Array) || narray?(i[0]))
                           end
      args.map do |xyzc|
        spec = nil
        case xyzc.last
        when String
          spec = xyzc.pop
        when Hash
          spec = xyzc.pop[:spec]
        end

        x, y, z, c = xyzc.map do |i|
          if i.is_a?(Array) || narray?(i) || i.nil?
            i
          elsif i.respond_to?(:to_a)
            # Convert an Array-like class such as Daru::Vector to an Array
            i.to_a
          else # String
            i
          end
        end
        [x, y, z, c, spec]
      end
    end

    # Normalize a color c with the range [cmin, cmax]
    #   0 <= normalize_color(c, cmin, cmax) <= 1
    def normalize_color(c, cmin, cmax)
      # NOTE: narray.map{|i| normalize_color(i)} There's room for speedup.
      c = c.to_f # if c is Integer
      c = c.clamp(cmin, cmax) - cmin
      c /= (cmax - cmin) if cmin != cmax
      c
    end

    def inqtext(x, y, s)
      s = s.to_s
      if s.length >= 2 && s[0] == '$' && s[-1] == '$'
        GR.inqmathtex(x, y, s[1..-2])
      elsif s.include?('\\') || s.include?('_') || s.include?('^')
        GR.inqtextext(x, y, s)
      else
        GR.inqtext(x, y, s)
      end
    end

    def text(x, y, s)
      s = s.to_s
      if s.length >= 2 && s[0] == '$' && s[-1] == '$'
        GR.mathtex(x, y, s[1..-2])
      elsif s.include?('\\') || s.include?('_') || s.include?('^')
        GR.textext(x, y, s)
      else
        GR.text(x, y, s)
      end
    end

    def fix_minmax(a, b)
      if a == b
        a -= a != 0 ? 0.1 * a : 0.1
        b += b != 0 ? 0.1 * b : 0.1
      end
      [a, b]
    end

    def minmax(kind)
      xmin = ymin = zmin = cmin = Float::INFINITY
      xmax = ymax = zmax = cmax = -Float::INFINITY
      scale = kvs[:scale]
      args.each do |x, y, z, c|
        if x
          if scale & GR::OPTION_X_LOG != 0
            # duck typing for NArray
            x = x.map { |v| v > 0 ? v : Float::NAN }
          end
          x0, x1 = x.minmax
          xmin = [x0, xmin].min
          xmax = [x1, xmax].max
        elsif kind == :volume
          xmin = -1
          xmax = 1
        else
          xmin = 0
          xmax = 1
        end
        if y
          if scale & GR::OPTION_Y_LOG != 0
            y = y.map { |v| v > 0 ? v : Float::NAN }
          end
          y0, y1 = y.minmax
          ymin = [y0, ymin].min
          ymax = [y1, ymax].max
        elsif kind == :volume
          ymin = -1
          ymax = 1
        else
          ymin = 0
          ymax = 1
        end
        if z
          if scale & GR::OPTION_Z_LOG != 0
            z = z.map { |v| v > 0 ? v : Float::NAN }
          end
          z0, z1 = z.minmax
          zmin = [z0, zmin].min
          zmax = [z1, zmax].max
        end
        if c
          c0, c1 = c.minmax
          cmin = [c0, cmin].min
          cmax = [c1, cmax].max
        elsif z
          z0, z1 = z.minmax
          cmin = [z0, zmin].min
          cmax = [z1, zmax].max
        end
      end
      xmin, xmax = fix_minmax(xmin, xmax)
      ymin, ymax = fix_minmax(ymin, ymax)
      zmin, zmax = fix_minmax(zmin, zmax)

      # kvs[:xlim], kvs[:ylim], kvs[:zlim] is supposed to be Array or Range
      kvs[:xrange] = [(kvs[:xlim]&.first || xmin), (kvs[:xlim]&.last || xmax)]
      kvs[:yrange] = [(kvs[:ylim]&.first || ymin), (kvs[:ylim]&.last || ymax)]
      kvs[:zrange] = [(kvs[:zlim]&.first || zmin), (kvs[:zlim]&.last || zmax)]

      if kvs.has_key?(:clim)
        c0, c1 = kvs[:clim]
        c0 ||= cmin
        c1 ||= cmax
        kvs[:crange] = [c0, c1]
      else
        kvs[:crange] = [cmin, cmax]
      end
    end

    def to_wc(wn)
      xmin, ymin = GR.ndctowc(wn[0], wn[2])
      xmax, ymax = GR.ndctowc(wn[1], wn[3])
      [xmin, xmax, ymin, ymax]
    end

    def auto_tick(amin, amax)
      scale = 10.0**Math.log10(amax - amin).truncate
      tick_size = [5.0, 2.0, 1.0, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01]
      i = tick_size.find_index do |tsize|
        ((amax - amin) / scale / tsize) > 7 # maximum number of tick marks
      end
      tick_size[i - 1] * scale
    end

    def legend_size
      scale = GR.inqscale
      GR.selntran(0)
      GR.setscale(0)
      w = 0
      h = 0
      kvs[:labels].each do |label|
        label = label.to_s
        tbx, tby = inqtext(0, 0, label)
        w = [w, tbx[2] - tbx[0]].max
        h += [tby[2] - tby[0], 0.03].max
      end
      GR.setscale(scale)
      GR.selntran(1)
      [w, h]
    end

    def equal_length(*args)
      GRCommons::GRCommonUtils.equal_length(*args)
    end

    def narray?(data)
      GRCommons::GRCommonUtils.narray?(data)
    end
  end

  class << self
    # (Plot) Draw one or more line plots.
    def plot(*args)
      create_plot(:line, *args)
    end

    # (Plot) Draw one or more step or staircase plots.
    def step(*args)
      create_plot(:step, *args)
    end

    # (Plot) Draw one or more scatter plots.
    def scatter(*args)
      create_plot(:scatter, *args)
    end

    # (Plot) Draw a stem plot.
    def stem(*args)
      create_plot(:stem, *args)
    end

    # (Plot)
    def polarhistogram(x, kv = {})
      plt = GR::Plot.new(x, kv)
      plt.kvs[:kind] = :polarhist
      nbins = plt.kvs[:nbins] || 0
      x, y = hist(x, nbins)
      plt.args = [[x, y, nil, nil, '']]
      plt.plot_data
    end

    # (Plot) Draw a heatmap.
    def heatmap(*args)
      # FIXME
      args, kv = format_xyzc(*args)
      _x, _y, z = args
      ysize, xsize = z.shape
      z = z.reshape(xsize, ysize)
      create_plot(:heatmap, kv) do |plt|
        plt.kvs[:xlim] ||= [0.5, xsize + 0.5]
        plt.kvs[:ylim] ||= [0.5, ysize + 0.5]
        plt.args = [[(1..xsize).to_a, (1..ysize).to_a, z, nil, '']]
      end
    end

    # (Plot) Draw a polarheatmap.
    def polarheatmap(*args)
      d = args.shift
      # FIXME
      z = Numo::DFloat.cast(d)
      raise 'expected 2-D array' unless z.ndim == 2

      create_plot(:polarheatmap, z, *args) do |plt|
        width, height = z.shape
        plt.kvs[:xlim] ||= [0.5, width + 0.5]
        plt.kvs[:ylim] ||= [0.5, height + 0.5]
        plt.args = [[(1..width).to_a, (1..height).to_a, z, nil, '']]
      end
    end

    # (Plot) Draw a nonuniformpolarheatmap.
    def nonuniformpolarheatmap(*args)
      # FIXME
      args, kv = format_xyzc(*args)
      _x, _y, z = args
      ysize, xsize = z.shape
      z = z.reshape(xsize, ysize)
      create_plot(:nonuniformpolarheatmap, kv) do |plt|
        plt.kvs[:xlim] ||= [0.5, xsize + 0.5]
        plt.kvs[:ylim] ||= [0.5, ysize + 0.5]
        plt.args = [[(1..xsize).to_a, (1..ysize).to_a, z, nil, '']]
      end
    end

    alias _contour_ contour
    # (Plot) Draw a contour plot.
    def contour(*args)
      create_plot(:contour, *format_xyzc(*args))
    end

    alias _contourf_ contourf
    # (Plot) Draw a filled contour plot.
    def contourf(*args)
      create_plot(:contourf, *format_xyzc(*args))
    end

    alias _hexbin_ hexbin
    # (Plot) Draw a hexagon binning plot.
    def hexbin(*args)
      create_plot(:hexbin, *args)
    end

    # (Plot) Draw a triangular contour plot.
    def tricont(*args)
      create_plot(:tricont, *format_xyzc(*args))
    end

    # (Plot) Draw a three-dimensional wireframe plot.
    def wireframe(*args)
      create_plot(:wireframe, *format_xyzc(*args))
    end

    # (Plot) Draw a three-dimensional surface plot.
    alias _surface_ surface
    def surface(*args)
      create_plot(:surface, *format_xyzc(*args))
    end

    # (Plot)
    def polar(*args)
      create_plot(:polar, *args)
    end

    # (Plot) Draw a triangular surface plot.
    def trisurf(*args)
      create_plot(:trisurf, *format_xyzc(*args))
    end

    # (Plot) Draw one or more three-dimensional line plots.
    def plot3(*args)
      create_plot(:plot3, *args)
    end

    # (Plot) Draw one or more three-dimensional scatter plots.
    def scatter3(*args)
      create_plot(:scatter3, *args)
    end

    alias _shade_ shade
    # (Plot)
    def shade(*args)
      create_plot(:shade, *args)
    end

    # (Plot)
    def volume(v, kv = {})
      create_plot(:volume, v, kv) do |plt|
        plt.args = [[nil, nil, v, nil, '']]
      end
    end

    # (Plot) Draw a bar plot.
    def barplot(labels, heights, kv = {})
      labels = labels.map(&:to_s)
      wc, hc = barcoordinates(heights)
      create_plot(:bar, labels, heights, kv) do |plt|
        if kv[:horizontal]
          plt.args = [[hc, wc, nil, nil, '']]
          plt.kvs[:yticks] = [1, 1]
          plt.kvs[:yticklabels] = labels
        else
          plt.args = [[wc, hc, nil, nil, '']]
          plt.kvs[:xticks] = [1, 1]
          plt.kvs[:xticklabels] = labels
        end
      end
    end

    # (Plot) Draw a histogram.
    def histogram(series, kv = {})
      create_plot(:hist, series, kv) do |plt|
        nbins = plt.kvs[:nbins] || 0
        x, y = hist(series, nbins)
        plt.args = if kv[:horizontal]
                     [[y, x, nil, nil, '']]
                   else
                     [[x, y, nil, nil, '']]
                   end
      end
    end

    # (Plot) Draw an image.
    def imshow(img, kv = {})
      img = Numo::DFloat.cast(img) # Umm...
      create_plot(:imshow, img, kv) do |plt|
        plt.args = [[nil, nil, img, nil, '']]
      end
    end

    # (Plot) Draw an isosurface.
    def isosurface(v, kv = {})
      v = Numo::DFloat.cast(v) # Umm...
      create_plot(:isosurface, v, kv) do |plt|
        plt.args = [[nil, nil, v, nil, '']]
      end
    end

    def hold(flag = true)
      plt = GR::Plot.last_plot
      plt.kvs.slice(:window, :scale, :xaxis, :yaxis, :zaxis).merge({ ax: flag, clear: !flag })
    end

    # Set current subplot index.
    def subplot(nr, nc, p, kv = {})
      xmin = 1
      xmax = 0
      ymin = 1
      ymax = 0
      p = [p] if p.is_a? Integer
      p.each do |i|
        r = (nr - (i - 1) / nc).to_f
        c = ((i - 1) % nc + 1).to_f
        xmin = [xmin, (c - 1) / nc].min
        xmax = [xmax, c / nc].max
        ymin = [ymin, (r - 1) / nr].min
        ymax = [ymax, r / nr].max
      end
      {
        subplot: [xmin, xmax, ymin, ymax],
        # The policy of clearing when p[0]==1 is controversial
        clear: p[0] == 1,
        update: p[-1] == nr * nc
      }.merge kv
    end

    # (Plot) Save the current figure to a file.
    def savefig(filename, kv = {})
      GR.beginprint(filename)
      plt = GR::Plot.last_plot
      plt.kvs.merge!(kv)
      plt.plot_data(false)
      GR.endprint
    end

    private

    def create_plot(type, *args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = type
      yield(plt) if block_given?
      plt.plot_data
      plt
    end

    def format_xyzc(*args)
      kv = if args[-1].is_a? Hash
             args.pop
           else
             {}
           end

      args = [args] unless args.all? do |i|
                             i.is_a?(Array) && (i[0].is_a?(Array) || narray?(i[0]))
                           end
      args.map! do |xyzc|
        if xyzc.size == 1
          if xyzc[0].is_a? Array
            z = Numo::DFloat.cast(xyzc[0])
          elsif narray?(xyzc[0])
            z = xyzc[0]
          end
          xsize, ysize = z.shape
          x = (1..ysize).to_a * xsize
          y = (1..xsize).map { |i| Array.new(ysize, i) }.flatten
          [x, y, z]
        else

          xyzc
        end
      end
      [*args, kv]
    end

    def hist(x, nbins = 0)
      nbins = (3.3 * Math.log10(x.length)).round + 1 if nbins <= 1
      begin
        require 'histogram/array'
      rescue LoadError => e
        e.message << " Please add gem 'histogram' to your project's Gemfile."
        raise e
      end
      x = x.to_a if narray?(x)
      x, y = x.histogram(nbins, bin_boundary: :min)
      x.push(x[-1] + x[1] - x[0])
      [x, y]
    end

    def barcoordinates(heights, barwidth = 0.8, baseline = 0.0)
      halfw = barwidth / 2.0
      wc = []
      hc = []
      heights.each_with_index do |value, i|
        wc << i - halfw
        wc << i + halfw
        hc << baseline
        hc << value
      end
      [wc, hc]
    end
  end
end
