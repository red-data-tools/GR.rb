# frozen_string_literal: true

module GRCommons
  module JupyterSupport
    # For IRuby Notebook
    if defined? IRuby
      require 'tempfile'
      ENV['GKSwstype'] = 'svg'
      @tempfile_svg = Tempfile.open(['plot', '.svg'])
      ENV['GKS_FILEPATH'] = @tempfile_svg.path
      def self.show
        emergencyclosegks
        sleep 0.5
        svg = File.read(@tempfile_svg.path)
        IRuby.display(svg, mime: 'image/svg+xml')
        nil
      end
    end
  end
end
