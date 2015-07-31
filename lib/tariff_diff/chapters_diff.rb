require_relative "base_diff"

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
      url = "chapters.json"
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
      url = "#{resource.pluralize}/#{id}.json"
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
  end
end
