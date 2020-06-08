# frozen_string_literal: true

require 'gr'

assets_dir = File.expand_path('assets', __dir__)
width, height, data = GR.readimage(File.join(assets_dir, 'ruby-logo.png'))

GR.drawimage(0, width / height.to_f, 0, 1, width, height, data)
GR.updatews
gets
