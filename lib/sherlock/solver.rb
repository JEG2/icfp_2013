require "json"

module Sherlock
  class Solver
    def initialize(api: API.new, io: $stdout, train: true, train_options: { })
      @api           = api
      @io            = io
      @strategies    = [ ]
      @train         = train
      @train_options = train_options
    end

    attr_reader :api, :io, :strategies, :train_options
    private     :api, :io, :strategies, :train_options

    def add_strategy(strategy)
      strategies << strategy
    end

    def solve
      problems do |problem|
        if (strategy = find_strategy(problem))
          io.puts "Solving:"
          io.puts JSON.pretty_generate(problem)
          guesser = strategy.new(problem, api: api, io: io)
          guesser.solve
          break unless guesser.continue?
        end
      end
    end

    def problems(&iterator)
      if train?
        training_problems(&iterator)
      else
        non_training_problems(&iterator)
      end
    end

    def find_strategy(problem)
      strategies.find { |strategy| strategy.can_handle?(problem) }
    end

    private

    def train?
      @train
    end

    def training_problems(&iterator)
      stream = Enumerator.new do |yielder|
        loop do
          result, problem = api.train(train_options)
          if result == :success
            yielder << problem
          else
            io.puts "Fetching problems failed:  #{result.to_s.tr('_', ' ')}"
            break
          end
        end
      end
      stream.each(&iterator)
    end

    def non_training_problems(&iterator)
      result, full_list = api.my_problems
      if result == :success
        Array(full_list).reject  { |problem| problem.include?("solved") }
                        .sort_by { |problem| problem["size"]            }
                        .each(&iterator)
      else
        io.puts "Fetching problems failed:  #{result.to_s.tr('_', ' ')}"
      end
    end
  end
end
