require "faraday"
require "json"

module Sherlock
  class API
    STATUS_CODES = { 200 => :success,
                     400 => :bad_request,
                     401 => :unauthorized,
                     403 => :authorization_required,
                     404 => :not_found,
                     410 => :gone,
                     412 => :already_solved,
                     413 => :request_too_big,
                     429 => :try_again_later }
    MAX_VECTOR   = 0xFFFFFFFFFFFFFFFF
    
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

    def eval(id: nil, program: nil, arguments: [ ])
      fail "ID or program is required" if     id.nil? && program.nil?
      fail "Invalid ID"                unless id.nil? ||
                                              (id.is_a?(String) && id =~ /\S/)
      fail "Invalid program"           unless program.nil? ||
                                              ( program.is_a?(String) &&
                                                program.size <= 1_024 )
      fail "Arguments are required"    unless arguments.is_a?(Array) &&
                                              !arguments.empty?
      fail "Too many arguments"        if     arguments.size > 256
      fail "Invalid arguments"         if     arguments.any? { |a|
                                                !a.between?(0, MAX_VECTOR)
                                              }

      params             = { }
      params[:id]        = id                           unless id.nil?
      params[:program]   = program                      unless program.nil?
      params[:arguments] = as_64_bit_vectors(arguments) unless program.nil?
      request(:eval, params)
    end

    def guess(id, program)
      request(:guess, id: id, program: program)
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

    def status
      request(:status)
    end

    private

    def request(action, params = { })
      response = ua.post(path(action)) do |request|
        request.body = params.to_json unless params.empty?
      end
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

    def as_64_bit_vectors(numbers)
      numbers.map { |n| "0x%016X" % n }
    end
  end
end
