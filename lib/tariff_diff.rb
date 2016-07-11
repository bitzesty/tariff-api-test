require 'byebug'
require_relative "hash"

require "faraday"
require "faraday_middleware"

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
