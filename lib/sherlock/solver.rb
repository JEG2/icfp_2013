require "json"

module Sherlock
  class Solver
    def initialize(api = API.new)
      @api        = api
      @strategies = [ ]
    end

    attr_reader :api, :strategies
    private     :api, :strategies

    def add_strategy(strategy)
      strategies << strategy
    end

    def solve
      problems do |problem|
        if (strategy = find_strategy(problem))
          puts "Solving:"
          puts JSON.pretty_generate(problem)
          strategy.new(problem, api).solve
        end
      end
    end

    def problems(&iterator)
      result, full_list = api.my_problems
      Array(full_list).reject  { |problem| problem.include?("solved") }
                      .sort_by { |problem| problem["size"]            }
                      .each(&iterator)
    end

    def find_strategy(problem)
      strategies.find { |strategy| strategy.can_handle?(problem) }
    end
  end
end
