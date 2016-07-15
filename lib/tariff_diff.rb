require 'byebug'
require 'active_support'
require 'active_support/all'
require 'diffy'
require "faraday"
require "faraday_middleware"
require 'logger'
LOG = Logger.new('diff.txt')
ERROR_LOG = Logger.new('errors.txt')

require_relative "tariff_diff/chapters_diff"
require_relative "tariff_diff/updates_diff"

class TariffDiff
  attr_reader :arguments

  def initialize(arguments)
    @arguments = arguments
  end

  def chapters_diff!
    ChaptersDiff.new(arguments).run!
  end

  def updates_diff!
    UpdatesDiff.new(arguments).run!
  end
end
