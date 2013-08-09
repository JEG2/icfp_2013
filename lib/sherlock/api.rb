require "faraday"
require "json"

module Sherlock
  class API
    def initialize(user_agent = Faraday)
      @token = File.read( File.join(File.dirname(__FILE__),
                          *%w[.. .. data token.txt]) ).strip
      @ua    = user_agent.new(url: "http://icfpc2013.cloudapp.net")
    end

    attr_reader :token, :ua
    private     :token, :ua

    def my_problems
      request(:myproblems)
    end

    private

    def request(action)
      response = ua.post(path(action))
      [result(response.status), content(response.body)]
    end

    def path(action)
      "/#{action}?auth=#{token}vpsH1H"
    end

    def result(code)
      case code
      when 200 then :success
      when 403 then :authorization_required
      when 429 then :try_again_later
      end
    end

    def content(body)
      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end
  end
end
