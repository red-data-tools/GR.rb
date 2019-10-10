# frozen_string_literal: true

module GRCommons
  module JupyterSupport
    # For IRuby Notebook

    if defined? IRuby
      def self.extended(_obj)
        require 'tempfile'
        ENV['GKSwstype'] = 'svg'
        # May be extended to both GR3 and GR
        ENV['GKS_FILEPATH'] = Tempfile.open(['plot', '.svg']).path
      end

      def show
        emergencyclosegks
        sleep 0.5
        svg = File.read(ENV['GKS_FILEPATH'])
        IRuby.display(svg, mime: 'image/svg+xml')
        nil
      end
    end
  end
end
