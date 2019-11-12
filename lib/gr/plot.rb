# frozen_string_literal: true

module GR
  # object oriented way
  class Plot
    def initialize(*args, kvs)
      # what if kvs is nil?
      @args = args
      @kvs = kvs
    end
    attr_accessor :args, :kvs

    def set_viewport(kind, subplot)
      mwidth, mheight, width, height = GR.inqdspsize
      if kvs[:figsize]
        w = 0.0254 * width * kvs[:figsize][0] / mwidth
        h = 0.0254 * height * kvs[:figsize][1] / mheight
      else
        dpi = width / mwidth * 0.0254
        if dpi > 200
          w. h = kvs[:size].map { |x| x * dp1 / 100 }
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
        vp[3] *= ratio
        vp[4] *= ratio
      else
        ratio = w / h.to_f
        msize = mheight * h / height
        GR.setwsviewport(0, msize * ratio, 0, msize)
        GR.setwswindow(0, ratio, 0, 1)
        vp[1] *= ratio
        vp[2] *= ratio
      end
      if %i[wireframe surface plot3 scatter3 trisurf volume].include?(kind)
        extent = [vp[2] - vp[1], vp[4] - vp[3]].min
        vp1 = 0.5 * (vp[1] + vp[2] - extent)
        vp2 = 0.5 * (vp[1] + vp[2] + extent)
        vp3 = 0.5 * (vp[3] + vp[4] - extent)
        vp4 = 0.5 * (vp[3] + vp[4] + extent)
      else
        vp1, vp2, vp3, vp4 = vp
      end
      viewport[1] = vp1 + 0.125 * (vp2 - vp1)
      viewport[2] = vp1 + 0.925 * (vp2 - vp1)
      viewport[3] = vp3 + 0.125 * (vp4 - vp3)
      viewport[4] = vp3 + 0.925 * (vp4 - vp3)
      if %i[contour contourf hexbin heatmap nonuniformheatmap polarheatmap surface trisurf volume].include?(kind)
        viewport[2] -= 0.1
      end

      if %i[line step scatter stem].include?(kind) && kvs[:labels]
        location = kvs[:location] # location may be array?
        if [11, 12, 13].include?(location)
          w, h = legend_size
          viewport[2] -= w + 0.1
        end
      end

      GR.setviewport(viewport[1], viewport[2], viewport[3], viewport[4])

      kvs[:viewport] = viewport
      kvs[:vp] = vp
      kvs[:ratio] = ratio

      if kvs[:backgroudcolor]
        GR.savestate
        GR.selntran(0)
        GR.setfillintstyle(GR::INTSTYLE_SOLID)
        GR.setfillcolorind(kvs[:backgroundcolor])
        if w > h
          GR.fillrect(subplot[1], subplot[2],
                      ratio * subplot[3], ratio * subplot[4])
        else
          GR.fillrect(ratio * subplot[1], ratio * subplot[2],
                      subplot[3], subplot[4])
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

    private

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
  end # Plot
end
