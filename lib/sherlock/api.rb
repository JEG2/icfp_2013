require "faraday"
require "json"

module Sherlock
  class API
    def initialize
      @token = File.read( File.join(File.dirname(__FILE__),
                          *%w[.. .. data token.txt]) ).strip
      @ua    = Faraday.new(url: "http://icfpc2013.cloudapp.net")
    end

    attr_reader :token, :ua

    def my_problems
      JSON.parse(ua.post(path(:myproblems)).body)
    end

    private

    def path(name)
      "/#{name}?auth=#{token}vpsH1H"
    end
  end
end
