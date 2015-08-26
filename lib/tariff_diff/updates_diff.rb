require_relative "base_diff"

class TariffDiff
  class UpdatesDiff < BaseDiff
    def run!
      updates_diff
      report
    end

    def report
      puts "\nFinished."
      puts "Found #{applied_updates[:common].count} common updates"
      hosts.each do |host|
        puts "#{applied_updates[host.to_sym].count} updates only on #{host}"
        applied_updates[host.to_sym].each do |update|
          puts "\t- #{update}"
        end
      end
    end

    private

    def applied_updates
      @applied_updates ||= {host1: [], host2: [], common: []}
    end

    def add_applied_update(list, update)
      unless applied_updates[list].include?(update)
        applied_updates[list] << update
      end
    end

    def compare_updates(host_updates)
      host_updates.each do |host, updates|
        against = host == :host1 ? :host2 : :host1
        updates.each do |update|
          if host_updates[against].include?(update)
            add_applied_update(:common, update)
          elsif applied_updates[against].include?(update)
            applied_updates[against].delete(update)
            add_applied_update(:common, update)
          elsif !applied_updates[:common].include?(update)
            add_applied_update(host, update)
          end
        end
      end
    end

    def updates_diff
      fetch_updates(page: 1)
    end

    def fetch_updates(options)
      url = "updates.json" + "?page=#{options[:page]}"
      puts "fetching page #{options[:page]}.."
      responses_for(url).tap do |responses|
        hosts_updates = responses.map do |response|
          response["updates"].map do |update|
            update["filename"]
          end
        end

        compare_updates({
          host1: hosts_updates[0],
          host2: hosts_updates[1]
        })

        max_page = max_page_for(responses)
        if options[:page] < max_page
          fetch_updates(page: options[:page]+1)
        end
      end
    end

    def max_page_for(responses)
      max_pages = responses.map do |response|
        pagination = response["pagination"]
        max_page = (pagination["total_count"] / pagination["per_page"].to_f).ceil
      end
      max_pages.max
    end
  end
end
