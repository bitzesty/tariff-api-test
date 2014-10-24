require_relative "hash"

require "faraday"
require "faraday_middleware"
require "active_support/inflector"

class TariffDiff
  attr_reader :host1, :host2, :resources_count

  def initialize(arguments)
    @resources_count = 0
    hosts.each do |host|
      conn = connection_for(arguments[host.to_sym], host)
      instance_variable_set :"@#{host}", conn
    end
  end

  def run!
    chapters_diff
    report
  end

  def report
    puts "\nFinished."
    puts "Compared #{resources_count} resources"
    puts "#{not_found.count} resource(s) not found"
    puts "#{not_matching.values.flatten.count} resource(s) don't match:"
    not_matching.each do |kind, resources|
      puts "\t#{kind}: #{resources.count}"
    end
  end

  def not_found
    # resources not found
    @not_found ||= []
  end

  def not_matching
    # resources not matching
    @not_matching ||= { chapters: [],
                        headings: [],
                        commodities: [] }
  end

  private

  def hosts
    @hosts ||= %w(host1 host2)
  end

  def chapters_diff
    url = "/chapters.json"
    responses_for(url).tap do |responses|
      if responses.first.to_s != responses.last.to_s
        puts "\nChapters don't match. Endpoint: #{url}"
      end
      # loop through chapters from first host
      responses.first.each do |chapter|
        chapter_id = chapter["goods_nomenclature_item_id"][0,2]
        chapter_diff(chapter_id)
      end
    end
  end

  def chapter_diff(id)
    chapter = diff_for "chapter", id
    chapter["headings"].each do |heading|
      heading_code = heading["goods_nomenclature_item_id"]
      heading_diff(heading_code[0,4]) # Heading#short_code
    end
  end

  def heading_diff(id)
    heading = diff_for "heading", id
    heading["commodities"].each do |commodity|
      commodity_id = commodity["goods_nomenclature_item_id"]
      diff_for "commodity", commodity_id
    end
  end

  def diff_for(resource, id=nil)
    @resources_count += 1
    url = "/#{resource.pluralize}/#{id}.json"
    responses = responses_for(url)
    if responses.first.to_s != responses.last.to_s
      puts "\n#{resource} #{id} doesn't match. Endpoint: #{url}"
      not_matching[resource.pluralize.to_sym] << id
      show_diff(responses) if responses.all?{|r| r.is_a?(Hash)}
    end
    responses.first
  end

  def show_diff(responses)
    puts "\tdiff:"
    puts "\thost1 (#{host1.url_prefix}):\n#{responses.first.diff(responses.last)}"
    puts "\thost2 (#{host2.url_prefix}):\n#{responses.last.diff(responses.first)}"
  end

  def responses_for(url)
    hosts.map { |h|
      host = send(h)
      host.get(url).tap do |response|
        if response.status == 404 # 404 urls
          full_url = response.env[:url].to_s
          puts "404: #{full_url}"
          not_found << full_url
        end
      end
    }.map(&:body)
  end

  def connection_for(url, host_name)
    Faraday.new(url: url) do |conn|
      conn.adapter Faraday.default_adapter
      conn.request :json
      conn.response :json, :content_type => /\bjson$/

      # setup basic auth (if needed)
      @user   = ENV["#{host_name}user"]
      @passwd = ENV["#{host_name}passwd"]
      if @user || @passwd
        conn.request :basic_auth, @user, @passwd
      end
    end
  end
end
