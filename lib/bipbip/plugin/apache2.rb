module Bipbip

  class Plugin::Apache2 < Plugin

    def metrics_schema
      [
          {:name => 'request_per_sec', :type => 'ce_gauge', :unit => 'Requests'},
          {:name => 'busy_workers', :type => 'ce_gauge', :unit => 'Workers'},
      ]
    end

    def monitor(server)
      uri = URI.parse(server['url'])
      response = Net::HTTP.get_response(uri)

      raise "Invalid response from server at #{server['url']}" unless response.code == '200'

      astats = response.body.split(/\r*\n/)

      ainfo = {}
      astats.each do |row|
        name, value = row.split(': ')
        ainfo[name] = value
      end

      {:request_per_sec => ainfo['ReqPerSec'].to_f, :busy_workers => ainfo['BusyWorkers'].to_i}
    end
  end
end
