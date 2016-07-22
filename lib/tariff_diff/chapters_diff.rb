require_relative "base_diff"
require 'json'

class TariffDiff
  class ChaptersDiff < BaseDiff
    attr_reader :resources_count

    DATE_AS_OF = "2016-07-22"

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
      url = "chapters.json?as_of=#{DATE_AS_OF}"
      responses_for(url).tap do |responses|
        if responses.first.to_s != responses.last.to_s
          LOG.info "\nChapters don't match. Endpoint: #{url}"
        end
        # loop through chapters from first host
        responses.map(&:body).first.each do |chapter|
          chapter_id = chapter["goods_nomenclature_item_id"][0,2]
          chapter_diff(chapter_id)
        end
      end
    end

    def chapter_diff(id)
      chapters_responses = get_responses_for "chapter", id
      chapters = chapters_responses.map(&:body)
      diff_for "chapter", id, chapters_responses

      chapters[0]["headings"].each do |heading|
        heading_code = heading["goods_nomenclature_item_id"]
        heading_diff(heading_code[0,4]) # Heading#short_code
      end
    end

    def heading_diff(id)
      headings_responses = get_responses_for "heading", id
      diff_for "heading", id, headings_responses
      headings = headings_responses.map(&:body)
      headings[0]["commodities"].each do |commodity|
        commodity_id = commodity["goods_nomenclature_item_id"]
        commodities_responses = get_responses_for "commodity", commodity_id
        diff_for  "commodity", commodity_id, commodities_responses
      end
    end

    def get_responses_for(resource, id=nil)
      url = "#{resource.pluralize}/#{id}.json?as_of=#{DATE_AS_OF}"
      responses_for(url)
    end

    def diff_for(resource, id, responses)
      if responses[0].status != 200
        puts "#{responses[0].env.url}: #{responses[0].status}"
      end
      if responses[1].status != 200
        puts "#{responses[1].env.url}: #{responses[1].status}"
      end
      return if responses[0].status != 200 || responses[1].status != 200
      first = responses[0].body
      if first['import_measures']
        first['import_measures'] = first['import_measures'].sort{|x,y|x['measure_sid'] <=> y['measure_sid']}
      end
      if first['export_measures']
        first['export_measures'] = first['export_measures'].sort{|x,y|x['measure_sid'] <=> y['measure_sid']}
      end

      second = responses[1].body
      if second['import_measures']
        second['import_measures'] = second['import_measures'].sort{|x,y|x['measure_sid'] <=> y['measure_sid']}
      end
      if second['export_measures']
        second['export_measures'] = second['export_measures'].sort{|x,y|x['measure_sid'] <=> y['measure_sid']}
      end

      LOG.info Diffy::Diff.new(JSON.pretty_generate(first), JSON.pretty_generate(second), :context => 5).to_s
    end
  end
end
