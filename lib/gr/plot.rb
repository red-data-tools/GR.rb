# frozen_string_literal: true

require 'gr'
autoload :GR3, 'gr3'

# FIXME: Plot should not depend on Numo::Narrray unless the GR3 module is required.
require 'numo/narray'

module GR
  class Plot # should be Figure ?
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
                   isosurface polar polarhist polarheatmap trisurf tricont shade
                   volume].freeze # the name might be changed in the future.

    # Keyword options conform to GR.jl.
    KW_ARGS = %i[accelerate algorithm alpha backgroundcolor barwidth baseline
                 clabels color colormap figsize isovalue labels levels location
                 nbins rotation size tilt title where xflip xform xlabel xlim
                 xlog yflip ylabel ylim ylog zflip zlabel zlim zlog clim
                 subplot].freeze

    @@last_plot
    def self.last_plot
      @@last_plot
    end

    def initialize(*args)
      @kvs = if args[-1].is_a? Hash
               args.pop
             else
               {}
             end
      @args = plot_args(args) # method name is the same as Julia/Python
      @kvs[:size] ||= [600, 450]
      @kvs[:ax] ||= false
      @kvs[:subplot] ||= [0, 1, 0, 1]
      @kvs[:clear] ||= true
      @kvs[:update] ||= true
      @scheme = 0
      @background = 0xffffff
      @handle = nil
      @@last_plot = self
    end
    attr_accessor :args, :kvs, :scheme

    def set_viewport(kind, subplot)
      mwidth, mheight, width, height = GR.inqdspsize
      if kvs[:figsize]
        w = 0.0254 * width * kvs[:figsize][0] / mwidth
        h = 0.0254 * height * kvs[:figsize][1] / mheight
      else
        dpi = width / mwidth * 0.0254
        if dpi > 200
          w, h = kvs[:size].map { |x| x * dpi / 100 }
        else
          w, h = kvs[:size]
        end
      end
      viewport = [0, 0, 0, 0]
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
      viewport[0] = vp1 + 0.125 * (vp2 - vp1)
      viewport[1] = vp1 + 0.925 * (vp2 - vp1)
      viewport[2] = vp3 + 0.125 * (vp4 - vp3)
      viewport[3] = vp3 + 0.925 * (vp4 - vp3)
      if %i[contour contourf hexbin heatmap nonuniformheatmap polarheatmap
            surface trisurf volume].include?(kind)
        viewport[1] -= 0.1
      end

      if %i[line step scatter stem].include?(kind) && kvs[:labels]
        location = kvs[:location] || 1
        if [11, 12, 13].include?(location)
          w, h = legend_size
          viewport[1] -= w + 0.1
        end
      end

      GR.setviewport(viewport[0], viewport[1], viewport[2], viewport[3])

      kvs[:viewport] = viewport
      kvs[:vp] = vp
      kvs[:ratio] = ratio

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

      if %i[polar polarhist polarheatmap].include? kind
        xmin, xmax, ymin, ymax = viewport
        xcenter = 0.5 * (xmin + xmax)
        ycenter = 0.5 * (ymin + ymax)
        r = 0.5 * [xmax - xmin, ymax - ymin].min
        GR.setviewport(xcenter - r, xcenter + r, ycenter - r, ycenter + r)
      end
    end

    def set_window(kind)
      scale = 0
      unless %i[polar polarhist polarheatmap].include?(kind)
        scale |= GR::OPTION_X_LOG if kvs[:xlog]
        scale |= GR::OPTION_Y_LOG if kvs[:ylog]
        scale |= GR::OPTION_Z_LOG if kvs[:zlog]
        scale |= GR::OPTION_FLIP_X if kvs[:xflip]
        scale |= GR::OPTION_FLIP_Y if kvs[:yflip]
        scale |= GR::OPTION_FLIP_Z if kvs[:zflip]
      end
      if kvs.key?(:panzoom)
        xmin, xmax, ymin, ymax = GR.panzoom(*kvs[:panzoom])
        kvs[:xrange] = [xmin, xmax]
        kvs[:yrange] = [ymin, ymax]
      else
        minmax
      end

      major_count = if %i[wireframe surface plot3 scatter3 polar polarhist
                          polarheatmap trisurf volume].include?(kind)
                      2
                    else
                      5
                    end

      xmin, xmax = kvs[:xrange]
      if (scale & GR::OPTION_X_LOG) == 0
        xmin, xmax = GR.adjustlimits(xmin, xmax) unless kvs.key?(:xlim) || kvs.key?(:panzoom)
        if kvs.key?(:xticks)
          xtick, majorx = kvs[:xticks]
        else
          majorx = major_count
          xtick = GR.tick(xmin, xmax) / majorx
        end
      else
        xtick = majorx = 1
      end
      xorg = if (scale & GR::OPTION_FLIP_X) == 0
               [xmin, xmax]
             else
               [xmax, xmin]
             end
      kvs[:xaxis] = xtick, xorg, majorx

      ymin, ymax = kvs[:yrange]
      if kind == :hist && !kvs.key?(:ylim)
        ymin = (scale & GR::OPTION_Y_LOG) == 0 ? 0 : 1
      end
      if (scale & GR::OPTION_Y_LOG) == 0
        ymin, ymax = GR.adjustlimits(ymin, ymax) unless kvs.key?(:ylim) || kvs.key?(:panzoom)
        if kvs.key?(:yticks)
          ytick, majory = kvs[:yticks]
        else
          majory = major_count
          ytick = GR.tick(ymin, ymax) / majory
        end
      else
        ytick = majory = 1
      end
      yorg = if (scale & GR::OPTION_FLIP_Y) == 0
               [ymin, ymax]
             else
               [ymax, ymin]
             end
      kvs[:yaxis] = ytick, yorg, majory

      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        zmin, zmax = kvs[:zrange]
        if (scale & GR::OPTION_Z_LOG) == 0
          zmin, zmax = GR.adjustlimits(zmin, zmax) if kvs.key?(:zlim)
          if kvs.key?(:zticks)
            ztick, majorz = kvs[:zticks]
          else
            majorz = major_count
            ztick = GR.tick(zmin, zmax) / majorz
          end
        else
          ztick = majorz = 1
        end
        zorg = if (scale & GR::OPTION_FLIP_Z) == 0
                 [zmin, zmax]
               else
                 [zmax, zmin]
               end
        kvs[:zaxis] = ztick, zorg, majorz
      end

      kvs[:window] = xmin, xmax, ymin, ymax
      if %i[polar polarhist polarheatmap].include?(kind)
        GR.setwindow(-1, 1, -1, 1)
      else
        GR.setwindow(xmin, xmax, ymin, ymax)
      end
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        rotation = kvs[:rotation] || 40
        tilt = kvs[:tilt] || 70
        GR.setspace(zmin, zmax, rotation, tilt)
      end

      kvs[:scale] = scale
      GR.setscale(scale)
    end

    def draw_axes(kind, pass = 1)
      viewport = kvs[:viewport]
      vp = kvs[:vp]
      ratio = kvs[:ratio]
      xtick, xorg, majorx = kvs[:xaxis]
      ytick, yorg, majory = kvs[:yaxis]
      drawgrid = kvs[:grid] || true
      xtick = 10 if kvs[:scale] & GR::OPTION_X_LOG != 0
      ytick = 10 if kvs[:scale] & GR::OPTION_Y_LOG != 0
      GR.setlinecolorind(1)
      diag = Math.sqrt((viewport[1] - viewport[0])**2 + (viewport[3] - viewport[2])**2)
      GR.setlinewidth(1)
      charheight = [0.018 * diag, 0.012].max
      GR.setcharheight(charheight)
      ticksize = 0.0075 * diag
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        ztick, zorg, majorz = kvs[:zaxis]
        if pass == 1 && drawgrid
          GR.grid3d(xtick, 0, ztick, xorg[0], yorg[1], zorg[0], 2, 0, 2)
          GR.grid3d(0, ytick, 0, xorg[0], yorg[1], zorg[0], 0, 2, 0)
        else
          GR.axes3d(xtick, 0, ztick, xorg[0], yorg[0], zorg[0], majorx, 0, majorz, -ticksize)
          GR.axes3d(0, ytick, 0, xorg[1], yorg[0], zorg[0], 0, majory, 0, ticksize)
        end
      else
        if %i[heatmap nonuniformheatmap shade].include?(kind)
          ticksize = -ticksize
        else
          drawgrid && GR.grid(xtick, ytick, 0, 0, majorx, majory)
        end
        if kvs.key?(:xticklabels) || kvs.key?(:yticklabels)
          fx = if kvs.key?(:xticklabels)
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
          fy = if kvs.key?(:yticklabels)
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

      if kvs.key?(:title)
        GR.savestate
        GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
        text(0.5 * (viewport[0] + viewport[1]), vp[3], kvs[:title])
        GR.restorestate
      end
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        xlabel = kvs[:xlabel] || ''
        ylabel = kvs[:ylabel] || ''
        zlabel = kvs[:zlabel] || ''
        GR.titles3d(xlabel, ylabel, zlabel)
      else
        if kvs.key?(:xlabel)
          GR.savestate
          GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_BOTTOM)
          text(0.5 * (viewport[0] + viewport[1]), vp[2] + 0.5 * charheight, kvs[:xlabel])
          GR.restorestate
        end
        if kvs.key?(:ylabel)
          GR.savestate
          GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
          GR.setcharup(-1, 0)
          text(vp[0] + 0.5 * charheight, 0.5 * (viewport[2] + viewport[3]), kvs[:ylabel])
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

      tick = 0.5 * GR.tick(rmin, rmax)
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
      linspace(0, 315, 8).each do |alpha|
        sinf = Math.sin(alpha * Math::PI / 180)
        cosf = Math.cos(alpha * Math::PI / 180)
        GR.polyline([cosf, 0], [sinf, 0])
        GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_HALF)
        x, y = GR.wctondc(1.1 * cosf, 1.1 * sinf)
        GR.textext(x, y, "%<alpha>g\xb0")
      end
      GR.restorestate
    end

    def plot_polar(θ, ρ)
      ρ = Numo::DFloat.cast(ρ) if ρ.is_a? Array
      window = kvs[:window]
      rmin = window[2]
      rmax = window[3]
      ρ = (ρ - rmin) / (rmax - rmin)
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
      viewport[3] -= 0.05 if kvs.key?(:title)
      vp = kvs[:vp]

      if img.is_a? String
        width, height, data = GR.readimage(img)
      else
        width, height = img.shape
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
      if kvs.key?(:xflip)
        tmp = xmax
        xmax = xmin
        xmin = tmp
      end
      if kvs.key?(:yflip)
        tmp = ymax
        ymax = ymin
        ymin = tmp
      end
      if img.is_a? String
        GR.drawimage(xmin, xmax, ymin, ymax, width, height, data)
      else
        GR.cellarray(xmin, xmax, ymin, ymax, width, height, data)
      end

      if kvs.key?(:title)
        GR.savestate
        GR.settextalign(GR::TEXT_HALIGN_CENTER, GR::TEXT_VALIGN_TOP)
        text(0.5 * (viewport[0] + viewport[1]), vp[3], kvs[:title])
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
      values = ((v - v.min) / (v.max - v.min) * (2 ^ 16 - 1)).round
      nx, ny, nz = v.shape
      isovalue = ((kvs[:isovalue] || 0.5) - v.min) / (v.max - v.min)
      rotation = ((kvs[:rotation] || 40) * Math::PI / 180.0)
      tilt = ((kvs[:tilt] || 70) * Math::PI / 180.0)
      r = 2.5
      GR3.clear
      mesh = GR3.createisosurfacemesh(values, [2.0 / (nx - 1), 2.0 / (ny - 1), 2.0 / (nz - 1)],
                                      [-1, -1, -1],
                                      (isovalue * (2 ^ 16 - 1)).round)
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
      options = if kvs.key?(:zflip)
                  (GR.inqscale | GR::OPTION_FLIP_Y)
                elsif kvs.key?(:yflip)
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
        ztick = 0.5 * GR.tick(zmin, zmax)
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

      set_viewport(kind, kvs[:subplot])
      unless kvs[:ax]
        set_window(kind)
        if %i[polar polarhist].include?(kind)
          draw_polar_axes
        elsif !%i[imshow isosurface polarheatmap].include?(kind)
          draw_axes(kind)
        end
      end

      if kvs.key?(:colormap)
        GR.setcolormap(kvs[:colormap])
      else
        GR.setcolormap(GR::COLORMAP_VIRIDIS)
      end

      GR.uselinespec(' ')
      args.each do |x, y, z, c, spec|
        # FIXME
        spec ||= ''
        GR.savestate
        GR.settransparency(kvs[:alpha]) if kvs.key?(:alpha)
        case kind
        when :line
          mask = GR.uselinespec(spec)
          GR.polyline(x, y) if hasline(mask)
          GR.polymarker(x, y) if hasmarker(mask)
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
          if z || c
            if c
              cmin, cmax = kvs[:crange]
              c = c.to_a if narray?(c)
              c.map! { |i| normalize_color(i, cmin, cmax) }
              cind = c.map { |i| (1000 + i * 255).round }
            end
            x.length.times do |i|
              GR.setmarkersize(z[i] / 100.0) if z
              GR.setmarkercolorind(cind[i]) if c
              GR.polymarker([x[i]], [y[i]])
            end
          else
            GR.polymarker(x, y)
          end
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
          ymin = kvs[:window][2]
          y.length.times do |i|
            GR.setfillcolorind(989)
            GR.setfillintstyle(GR::INTSTYLE_SOLID)
            GR.fillrect(x[i], x[i + 1], ymin, y[i])
            GR.setfillcolorind(1)
            GR.setfillintstyle(GR::INTSTYLE_HOLLOW)
            GR.fillrect(x[i], x[i + 1], ymin, y[i])
          end
        # when :polarhist
        #   xmin, xmax = x.minmax
        #   ymax = kvs[:window][3]
        #   ρ = y.map { |i| 2 * (i.to_f / ymax - 0.5) }
        #   θ = x.map { |i| 2 * Math::PI * (i.to_f - xmin) / (xmax - xmin) }
        #   ρ.length.times do |i|
        #     GR.setfillcolorind(989)
        #     GR.setfillintstyle(GR::INTSTYLE_SOLID)
        #     GR.fillarea([0, ρ[i] * Math.cos(θ[i]), ρ[i] * Math.cos(θ[i + 1])],
        #                 [0, ρ[i] * Math.sin(θ[i]), ρ[i] * Math.sin(θ[i + 1])])
        #     GR.setfillcolorind(1)
        #     GR.setfillintstyle(GR::INTSTYLE_HOLLOW)
        #     GR.fillarea([0, ρ[i] * Math.cos(θ[i]), ρ[i] * Math.cos(θ[i + 1])],
        #                 [0, ρ[i] * Math.sin(θ[i]), ρ[i] * Math.sin(θ[i + 1])])
        #   end
        when :polarheatmap
          w, h = z.shape
          cmap = colormap
          cmin, cmax = kvs[:zrange]
          data = z.map { |i| normalize_color(i, cmin, cmax) }
          colors = data.map { |i| 1000 + i * 255 }
          # if kvs[:xflip]
          # if kvs[;yflip]
          GR.polarcellarray(0, 0, 0, 360, 0, 1, w, h, colors)
          draw_polar_axes
          kvs[:zrange] = [cmin, cmax]
          colorbar
        when :contour, :contourf
          zmin, zmax = kvs[:zrange]
          if narray?(z) && z.ndim == 2
            a, b = z.shape
            x = (1..b).to_a
            y = (1..a).to_a
            zmin, zmax = kvs[:zlim] || z.minmax
          elsif equal_length(x, y, z)
            x, y, z = GR.gridit(x, y, z, 200, 200)
            zmin, zmax = kvs[:zlim] || z.compact.minmax # compact : removed nil
          end
          GR.setspace(zmin, zmax, 0, 90)
          levels = kvs[:levels] || 0
          clabels = kvs[:clabels] || false
          if levels.is_a? Integer
            hmin, hmax = GR.adjustrange(zmin, zmax)
            h = linspace(hmin, hmax, levels == 0 ? 21 : levels + 1)
          else
            h = levels
          end
          if kind == :contour
            GR._contour_(x, y, h, z, clabels ? 1 : 1000)
          elsif kind == :contourf
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
          GR.polyline3d(x, y, z)
          draw_axes(kind, 2)
        when :scatter3
          GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
          if c
            cmin, cmax = kvs[:crange]
            c = c.map { |i| normalize_color(i, cmin, cmax) } # NArray -> Array
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
          GR._trisurface_(x, y, z)
          draw_axes(kind, 2)
          colorbar(0.05)
        when :tricont
          zmin, zmax = kvs[:zrange]
          levels = linspace(zmin, zmax, 20)
          GR._tricontour_(x, y, z, levels)
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

      draw_legend if %i[line step scatter stem].include?(kind) && kvs.key?(:labels)

      if kvs.key?(:update)
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
          tbx, tby = inqtext(0, 0, label)
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
          GR.text(px, py, label)
          py -= 0.5 * dy
          i += 1
        end
        py -= 0.03
        GR.selntran(1)
        GR.restorestate
      end
    end

    def to_svg
      ## Need IRuby improvemend.
      GR.show(false) if ENV['GKSwstype'] == 'svg'
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

    def plot_args(args, _fmt = :xys)
      # FIXME
      x, y, z, c = args.map do |i|
        # Convert an Array-like class such as Daru::Vector to an Array
        i.is_a?(Array) || narray?(i) ? i : i.to_a
      end
      [[x, y, z, c]]
    end

    # Normalize a color c with the range [cmin, cmax]
    #   0 <= normalize_color(c, cmin, cmax) <= 1
    def normalize_color(c, cmin, cmax)
      c = c.clamp(cmin, cmax) - cmin
      c /= (cmax - cmin) if cmin != cmax
      c
    end

    def inqtext(x, y, s)
      if s.length >= 2 && s[0] == '$' && s[-1] == '$'
        GR.inqmathtex(x, y, s[1..-2])
      elsif s.include?('\\') || s.include?('_') || s.include?('^')
        GR.inqtextext(x, y, s)
      else
        GR.inqtext(x, y, s)
      end
    end

    def text(x, y, s)
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

    def minmax
      xmin = ymin = zmin = cmin = Float::INFINITY
      xmax = ymax = zmax = cmax = -Float::INFINITY

      args.each do |x, y, z, c|
        if x
          x0, x1 = x.minmax
          xmin = [x0, xmin].min
          xmax = [x1, xmax].max
        else
          xmin = 0
          xmax = 1
        end
        if y
          y0, y1 = y.minmax
          ymin = [y0, ymin].min
          ymax = [y1, ymax].max
        else
          ymin = 0
          ymax = 1
        end
        if z
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
      if kvs.key?(:xlim)
        x0, x1 = kvs[:xlim]
        x0 ||= xmin
        x1 ||= xmax
        kvs[:xrange] = [x0, x1]
      else
        kvs[:xrange] = [xmin, xmax]
      end
      if kvs.key?(:ylim)
        y0, y1 = kvs[:ylim]
        y0 ||= ymin
        y1 ||= ymax
        kvs[:yrange] = [y0, y1]
      else
        kvs[:yrange] = [ymin, ymax]
      end
      if kvs.key?(:zlim)
        z0, z1 = kvs[:zlim]
        z0 ||= zmin
        z1 ||= zmax
        kvs[:zrange] = [z0, z1]
      else
        kvs[:zrange] = [zmin, zmax]
      end
      if kvs.key?(:clim)
        c0, c1 = kvs[:clim]
        c0 ||= cmin
        c1 ||= cmax
        kvs[:crange] = [c0, c1]
      else
        kvs[:crange] = [cmin, cmax]
      end
    end

    def legend_size
      scale = GR.inqscale
      GR.selntran(0)
      GR.setscale(0)
      w = 0
      h = 0
      kvs[:labels].each do |label|
        tbx, tby = inqtext(0, 0, label)
        w = [w, tbx[2]].max
        h += [tby[2] - tby[0], 0.03].max
      end
      GR.setscale(scale)
      GR.selntran(1)
      [w, h]
    end

    # NOTE: duplicated definition (GRCommonUtils)
    def equal_length(*args)
      lengths = args.map(&:length)
      unless lengths.all? { |l| l == lengths[0] }
        raise ArgumentError,
              'Sequences must have same length.'
      end

      lengths[0]
    end

    # NOTE: duplicated definition (GRCommonUtils)
    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end
  end

  class << self
    # line plot
    def plot(*args)
      create_plot(:line, *args)
    end

    def step(*args)
      create_plot(:step, *args)
    end

    def scatter(*args)
      create_plot(:scatter, *args)
    end

    def scatter3(*args)
      create_plot(:scatter3, *args)
    end

    def stem(*args)
      create_plot(:stem, *args)
    end

    def histogram(x, kv = {})
      create_plot(:hist, x, kv) do |plt|
        nbins = plt.kvs[:nbins] || 0
        x, y = hist(x, nbins)
        plt.args = [[x, y, nil, nil, '']]
      end
    end

    # def polarhistogram(x, kv = {})
    #   plt = GR::Plot.new(x, kv)
    #   plt.kvs[:kind] = :polarhist
    #   nbins = plt.kvs[:nbins] || 0
    #   x, y = hist(x, nbins)
    #   plt.args = [[x, y, nil, nil, '']]
    #   plt.plot_data
    # end

    def heatmap(*args)
      # FIXME
      _x, _y, z, kv = parse_args(*args)
      ysize, xsize = z.shape
      z = z.reshape(xsize, ysize)
      create_plot(:heatmap, kv) do |plt|
        plt.kvs[:xlim] ||= [0.5, xsize + 0.5]
        plt.kvs[:ylim] ||= [0.5, ysize + 0.5]
        plt.args = [[(1..xsize).to_a, (1..ysize).to_a, z, nil, '']]
      end
    end

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

    alias _contour_ contour
    def contour(*args)
      x, y, z, kv = parse_args(*args)
      create_plot(:contour, x, y, z, kv)
    end

    alias _contourf_ contourf
    def contourf(*args)
      x, y, z, kv = parse_args(*args)
      create_plot(:contourf, x, y, z, kv)
    end

    alias _hexbin_ hexbin
    def hexbin(*args)
      create_plot(:hexbin, *args)
    end

    alias _tricontour_ tricontour
    def tricontour(*args)
      x, y, z, kv = parse_args(*args)
      create_plot(:tricont, x, y, z, kv)
    end

    alias _surface_ surface
    def surface(*args)
      x, y, z, kv = parse_args(*args)
      create_plot(:surface, x, y, z, kv)
    end

    def polar(*args)
      create_plot(:polar, *args)
    end

    alias _trisurface_ trisurface
    def trisurface(*args)
      x, y, z, kv = parse_args(*args)
      create_plot(:trisurf, x, y, z, kv)
    end

    def wireframe(*args)
      x, y, z, kv = parse_args(*args)
      create_plot(:wireframe, x, y, z, kv)
    end

    def plot3(*args)
      create_plot(:plot3, *args)
    end

    alias _shade_ shade
    def shade(*args)
      create_plot(:shade, *args)
    end

    def volume(v, kv = {})
      create_plot(:volume, v, kv) do |plt|
        plt.args = [[nil, nil, v, nil, '']]
      end
    end

    def barplot(labels, heights, kv = {})
      labels = labels.map(&:to_s)
      wc, hc = barcoordinates(heights)
      horizontal = kv[:horizontal] || false
      create_plot(:bar, labels, heights, kv) do |plt|
        if horizontal
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

    def imshow(img, kv = {})
      img = Numo::DFloat.cast(img) # Umm...
      create_plot(:imshow, img, kv) do |plt|
        plt.args = [[nil, nil, img, nil, '']]
      end
    end

    def isosurface(v, kv = {})
      v = Numo::DFloat.cast(v) # Umm...
      create_plot(:isosurface, v, kv) do |plt|
        plt.args = [[nil, nil, v, nil, '']]
      end
    end

    def savefig(filename)
      GR.beginprint(filename)
      GR::Plot.last_plot.plot_data(false)
      GR.endprint
    end

    private

    def create_plot(type, *args, &block)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = type
      block.call(plt) if block_given?
      plt.plot_data
      plt
    end

    def parse_args(*args)
      kv = if args[-1].is_a? Hash
             args.pop
           else
             {}
           end
      if args.size == 1
        if args[0].is_a? Array
          z = Numo::DFloat.cast(args[0])
        elsif narray?(args[0])
          z = args[0]
        end
        xsize, ysize = z.shape
        # NOTE:
        # See
        # https://github.com/jheinen/GR.jl/pull/246
        # https://github.com/jheinen/GR.jl/issues/241
        x = (1..ysize).to_a * xsize
        y = (1..xsize).map { |i| Array.new(ysize, i) }.flatten

      elsif args.size == 3
        x, y, z = args
      else
        raise
      end
      [x, y, z, kv]
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
