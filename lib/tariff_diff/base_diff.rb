require "active_support/inflector"

class TariffDiff
  class BaseDiff
    attr_reader :host1, :host2

    def initialize(arguments)
      hosts.each do |host|
        conn = connection_for(arguments[host.to_sym], host)
        instance_variable_set :"@#{host}", conn
      end
    end

    def not_found
      # resources not found
      @not_found ||= []
    end

    private

    def hosts
      @hosts ||= %w(host1 host2)
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
end
