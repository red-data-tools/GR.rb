# frozen_string_literal: true

require 'gr'

width, height, data = GR.readimage(File.expand_path('ruby-logo.png', __dir__))
GR.drawimage(0, width / height.to_f, 0, 1, width, height, data)
GR.updatews
gets
