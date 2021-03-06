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
      puts url
      hosts.map do |h|
        host = send(h)
        host.get(url).tap do |response|
          if response.status != 200
            full_url = response.env[:url].to_s
            ERROR_LOG.info "ERROR: #{full_url}"
            not_found << full_url
          end
        end
      end
    end

    def connection_for(url, host_name)
      Faraday.new(url: url) do |conn|
        conn.use FaradayMiddleware::FollowRedirects, limit: 3
        conn.request :json
        conn.response :json, :content_type => /\bjson$/
        # conn.response :logger

        # setup basic auth (if needed)
        @user   = ENV["#{host_name}user"]
        @passwd = ENV["#{host_name}passwd"]
        if @user || @passwd
          conn.request :basic_auth, @user, @passwd
          conn.adapter :net_http
        end

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
