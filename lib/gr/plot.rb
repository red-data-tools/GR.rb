# frozen_string_literal: true

module GR
  # object oriented way
  class Plot # should be Figure ?
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
      if %i[contour contourf hexbin heatmap nonuniformheatmap polarheatmap surface trisurf volume].include?(kind)
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

      if kvs[:backgroudcolor]
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

      major_count = if %i[wireframe surface plot3 scatter3 polar polarhist polarheatmap trisurf volume].include?(kind)
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
      if kind == :hist && kvs.key?(:ylim)
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
        # if kvs.key?(:xticklabels) || kvs.key?(:yticklabels)
        #    fx = get(plt.kvs, :xticklabels, identity) |> ticklabel_fun
        #    fy = get(plt.kvs, :yticklabels, identity) |> ticklabel_fun
        #    GR.axeslbl(xtick, ytick, xorg[1], yorg[1], majorx, majory, ticksize, fx, fy)
        # else
        GR.axes(xtick, ytick, xorg[0], yorg[0], majorx, majory, ticksize)
        # end
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
          text(vp[0] + 0.5 * charheight, 0.5 * (viewport[2] + viewport[3]), plt.kvs[:ylabel])
          GR.restorestate
        end
      end
    end

    def colorbar(off = 0, colors = 256)
      GR.savestate
      viewport = kvs[:viewport]
      zmin, zmax = kvs[:zrange]
      mask = (GR::OPTION_Z_LOG | GR::OPTION_FLIP_Y | GR::OPTION_FLIP_Z)
      if kvs.key?(:zflip)
        options = (GR.inqscale | GR::OPTION_FLIP_Y)
        GR.setscale(options & mask)
      elsif kvs.key?(:yflip)
        options = GR.inqscale & ~GR::OPTION_FLIP_Y
        GR.setscale(options & mask)
      else
        options = GR.inqscale
        GR.setscale(options & mask)
      end
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
        GR.setcolormap(plt.kvs[:colormap])
      else
        GR.setcolormap(GR::COLORMAP_VIRIDIS)
      end

      GR.uselinespec(' ')
      args.each do |x, y, z, c, _spec|
        GR.savestate
        GR.settransparency(kvs[:alpha]) if kvs.key?(:alpha)
        case kind
        when :line
          mask = GR.uselinespec(spec = '')
          GR.polyline(x, y) if [0, 1, 3, 4, 5].include?(mask)
          GR.polymarker(x, y) if (mask & 2) != 0
        when :step
        when :scatter
          GR.setmarkertype(GR::MARKERTYPE_SOLID_CIRCLE)
          if z || c
            if c
              cmin, cmax = kvs[:crange]
              c = c.to_a if narray?(c)
              c.map! { |x| normalize_color(x, cmin, cmax) }
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
          GR.uselinespec(spec = '')
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
        when :polarhist
        when :polarheatmap
        when :contour
          zmin, zmax = kvs[:zrange]
          if x.length == y.length && y.length == z.length
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
          GR.contour(x, y, h, z, clabels ? 1 : 1000)
          colorbar(0, h.length)
        when :contourf
          zmin, zmax = kvs[:zrange]
          if x.length == y.length && y.length == z.length
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
          GR.contourf(x, y, h, z, clabels ? 1 : 0)
          colorbar(0, h.length)
        when :hexbin
          nbins = kvs[:nbins] || 40
          cntmax = GR.hexbin(x, y, nbins)
          if cntmax > 0
            kvs[:zrange] = [0, cntmax]
            colorbar
          end
        when :heatmap, :nonuniformheatmap
        when :wireframe
          x, y, z = GR.gridit(x, y, z, 50, 50) if x.length == y.length && y.length == z.length
          GR.setfillcolorind(0)
          GR.surface(x, y, z, GR::OPTION_FILLED_MESH)
          draw_axes(kind, 2)
        when :surface
          x, y, z = GR.gridit(x, y, z, 200, 200) if x.length == y.length || y.length == z.length
          if kvs[:accelerate] == false
            GR.surface(x, y, z, GR::OPTION_COLORED_MESH)
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
            c = c.map { |x| normalize_color(x, cmin, cmax) } # NArray -> Array
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
        when :isosurface
        when :polar
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

    def draw_legend; end

    private

    # https://gist.github.com/rysk-t/8d1aef0fb67abde1d259#gistcomment-1925021
    def linspace(low, high, num)
      [*0..(num - 1)].collect { |i| low + i.to_f * (high - low) / (num - 1) }
    end

    def plot_args(args, _fmt = :xys)
      # :construction:
      x, y, z, c = args
      [[x, y, z, c]]
    end

    # Normalize a color c with the range [cmin, cmax]
    #   0 <= normalize_color(c, cmin, cmax) <= 1
    def normalize_color(c, cmin, cmax)
      c = c.clamp(cmin, cmax) - cmin
      c /= (cmax - cmin) if cmin != cmax
      c
    end

    def text(x, y, s)
      if s.length >= 2 && s[0] == '$' && s[-1] == '$'
        GR.mathtex(x, y, s[1..-2])
      elsif s.include('\\') || s.include?('_') || s.include?('^')
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
        w = [w, tbx[3]].max
        h += [tby[3] - tby[1], 0.03].max
      end
      GR.setscale(scale)
      GR.selntran(1)
      [w, h]
    end

    def narray?(data)
      defined?(Numo::NArray) && data.is_a?(Numo::NArray)
    end
  end # Plot

  class << self
    def lineplot(*args)
      plt = GR::Plot.new(*args)
      plt.plot_data
    end

    def scatterplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :scatter
      plt.plot_data
    end

    def scatterplot3(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :scatter3
      plt.plot_data
    end

    def stemplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :stem
      plt.plot_data
    end

    def histogram(x, kv = {})
      plt = GR::Plot.new(x, kv)
      plt.kvs[:kind] = :hist
      nbins = plt.kvs[:nbins] || 0
      x, y = hist(x, nbins)
      plt.args = [[x, y, nil, nil, '']]
      plt.plot_data
    end

    # def polarhistogram(x, kv = {})
    #   plt = GR::Plot.new(x, kv)
    #   plt.kvs[:kind] = :polarhist
    #   nbins = plt.kvs[:nbins] || 0
    #   x, y = hist(x, nbins)
    #   plt.args = [[x, y, nil, nil, '']]
    #   plt.plot_data
    # end

    def contourplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :contour
      plt.plot_data
    end

    def contourfplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :contourf
      plt.plot_data
    end

    def hexbinplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :hexbin
      plt.plot_data
    end

    def tricontourplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :tricont
      plt.plot_data
    end

    def surfaceplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :surface
      plt.plot_data
    end

    def trisurfaceplot(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :trisurf
      plt.plot_data
    end

    def wireframe(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :wireframe
      plt.plot_data
    end

    def lineplot3(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :plot3
      plt.plot_data
    end

    def shade(*args)
      plt = GR::Plot.new(*args)
      plt.kvs[:kind] = :shade
      plt.plot_data
    end

    def volumeplot(v, kv = {})
      plt = GR::Plot.new(v, kv)
      plt.kvs[:kind] = :volume
      plt.args = [[nil, nil, v, nil, '']]
      plt.plot_data
    end

    private

    def hist(x, nbins = 0)
      nbins = (3.3 * Math.log10(x.length)).round + 1 if nbins <= 1
      require 'histogram/array' # dependency
      x = x.to_a if narray?(x)
      x, y = x.histogram(nbins, bin_boundary: :min)
      x.unshift(x.min)
      [x, y]
    end
  end
end
