# frozen_string_literal: true

require_relative 'test_helper'
require 'tmpdir'

module IRuby
  class << self
    attr_accessor :displays

    def display(data, mime:)
      self.displays ||= []
      displays << [data, mime]
    end
  end
end

# Jupyter support is conditional on IRuby being available when the file is
# evaluated, so reload it after installing the small test double above.
load File.expand_path('../lib/gr_commons/jupyter_support.rb', __dir__)

class JupyterSupportTest < Test::Unit::TestCase
  def setup
    @old_wstype = ENV.fetch('GKS_WSTYPE', nil)
    @old_filepath = ENV.fetch('GKS_FILEPATH', nil)
    IRuby.displays = []
    @host = Object.new
    @host.define_singleton_method(:emergencyclosegks) {}
    @host.define_singleton_method(:sleep) { |_duration| }
    @host.extend(GRCommons::JupyterSupport)
  end

  def teardown
    ENV['GKS_WSTYPE'] = @old_wstype
    ENV['GKS_FILEPATH'] = @old_filepath
  end

  def test_extending_configures_svg_output
    assert_equal 'svg', ENV.fetch('GKS_WSTYPE')
    assert_match(%r{/plot-}, ENV.fetch('GKS_FILEPATH'))
  end

  def test_image_formats
    {
      'svg' => ['svg', 'image/svg+xml'],
      'png' => ['png', 'image/png'],
      'jpg' => ['jpg', 'image/jpeg'],
      'gif' => ['gif', 'image/gif']
    }.each do |type, (extension, mime)|
      with_output(type, extension, "#{type}-data") do
        assert_nil @host.show
        assert_equal ["#{type}-data", mime], IRuby.displays.last
      end
    end
  end

  def test_show_can_return_data_without_displaying_it
    with_output('png', 'png', 'raw-png') do
      assert_equal 'raw-png', @host.show(false)
      assert_empty IRuby.displays
    end
  end

  def test_video_formats
    { 'webm' => 'video/webm', 'mov' => 'movie/quicktime' }.each do |type, mime|
      with_output(type, type, "#{type}-data") do
        assert_nil @host.show
        html, displayed_mime = IRuby.displays.last
        assert_equal 'text/html', displayed_mime
        assert_include html, "type=\"#{mime}\""
        assert_include html, "data:#{mime};base64,"
      end
    end
  end

  def test_video_can_be_returned_without_displaying_it
    with_output('mp4', 'mp4', "\x00video".b) do
      assert_equal "\x00video".b, @host.show(false)
      assert_empty IRuby.displays
    end
  end

  private

  def with_output(type, extension, data)
    Dir.mktmpdir do |directory|
      ENV['GKS_WSTYPE'] = type
      ENV['GKS_FILEPATH'] = File.join(directory, 'plot')
      File.binwrite("#{ENV.fetch('GKS_FILEPATH')}.#{extension}", data)
      yield
    end
  end
end
