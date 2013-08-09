require "faraday"
require "json"

module Sherlock
  class API
    STATUS_CODES = { 200 => :success,
                     400 => :bad_request,
                     403 => :authorization_required,
                     429 => :try_again_later }

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

    def train(size: nil, operators: nil)
      fail "Invalid size" unless size.nil? ||
                                 (size.is_a?(Integer) && size.between?(3, 30))

      allowed_operater = operators.to_s.delete("^a-z")
      fail "Invalid operators" unless allowed_operater.empty? ||
                                      %w[tfold fold].include?(allowed_operater)

      params             = { }
      params[:size]      = size \
        unless size.nil?
      params[:operators] = %Q{["#{allowed_operater}"]} \
        unless allowed_operater.empty?
      request(:train, params)
    end

    private

    def request(action, params = { })
      response = ua.post(path(action), params)
      [result(response.status), content(response.body)]
    end

    def path(action)
      "/#{action}?auth=#{token}vpsH1H"
    end

    def result(code)
      STATUS_CODES.fetch(code)
    end

    def content(body)
      return body unless body.is_a?(String)

      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end
  end
end
