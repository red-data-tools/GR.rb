# frozen_string_literal: true

require 'bundler/setup'
Bundler.require(:test)

require 'simplecov'
SimpleCov.start

require 'test/unit'
require 'numo/narray'
