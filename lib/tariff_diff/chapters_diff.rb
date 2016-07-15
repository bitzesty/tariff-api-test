require_relative "base_diff"
require 'json'

class TariffDiff
  class ChaptersDiff < BaseDiff
    attr_reader :resources_count

    def run!
      @resources_count = 0
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

    def not_matching
      # resources not matching
      @not_matching ||= { chapters: [],
                          headings: [],
                          commodities: [] }
    end

    private

    def chapters_diff
      url = "chapters.json?as_of=2016-07-10"
      responses_for(url).tap do |responses|
        if responses.first.to_s != responses.last.to_s
          LOG.info "\nChapters don't match. Endpoint: #{url}"
        end
        # loop through chapters from first host
        responses.first.each do |chapter|
          chapter_id = chapter["goods_nomenclature_item_id"][0,2]
          chapter_diff(chapter_id)
        end
      end
    end

    def chapter_diff(id)
      chapters = get_responses_for "chapter", id
      diff_for "chapter", id, chapters.dup

      chapters[0]["headings"].each do |heading|
        heading_code = heading["goods_nomenclature_item_id"]
        heading_diff(heading_code[0,4]) # Heading#short_code
      end
    end

    def heading_diff(id)
      headings = get_responses_for "heading", id
      diff_for "heading", id, headings.dup
      headings[0]["commodities"].each do |commodity|
        commodity_id = commodity["goods_nomenclature_item_id"]
        commodities = get_responses_for "commodity", commodity_id
        diff_for  "commodity", commodity_id, commodities
      end
    end

    def get_responses_for(resource, id=nil)
      url = "#{resource.pluralize}/#{id}.json?as_of=2016-07-10"
      responses_for(url)
    end

    def diff_for(resource, id, responses)
      # byebug
      return if responses[0].has_key?("error") || responses[1].has_key?("error")
      LOG.info Diffy::Diff.new(JSON.pretty_generate(responses[0]), JSON.pretty_generate(responses[1]), :context => 5).to_s
    end
  end
end
